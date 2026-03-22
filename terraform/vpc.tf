# Main Network
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = { Name = "url-shortener-vpc" }
}

# Public subnet — EC2 will be here
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  # Public subnet for internet-facing EC2/bastion/NAT test instance
  # nosemgrep: terraform.aws.security.aws-subnet-has-public-ip-address.aws-subnet-has-public-ip-address
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"

  tags = { Name = "url-shortener-public" }
}

# Private subnet — there will be RDS here
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-1a"

  tags = { Name = "url-shortener-private-a" }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-southeast-1b"

  tags = { Name = "url-shortener-private-b" }
}

# Internet Gateway — gives EC2 internet access
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "url-shortener-igw" }
}

# Route table — directs traffic through the gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "url-shortener-public-rt" }
}

# Linking the route table to a public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Subnet group for RDS
resource "aws_db_subnet_group" "main" {
  name       = "url-shortener-db-subnet"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = { Name = "url-shortener-db-subnet-group" }
}
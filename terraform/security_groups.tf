# Security Group for EC2
resource "aws_security_group" "app" {
  name   = "url-shortener-app-sg"
  vpc_id = aws_vpc.main.id

  # HTTP — accessible to everyone
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH — open for GitHub Actions, key-based auth only (0.0.0.0 - studying project purposes only)
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

  # Outbound traffic — fully allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "url-shortener-app-sg" }
}

# Security Group for RDS
resource "aws_security_group" "db" {
  name   = "url-shortener-db-sg"
  vpc_id = aws_vpc.main.id

  # PostgreSQL — only from EC2
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "url-shortener-db-sg" }
}
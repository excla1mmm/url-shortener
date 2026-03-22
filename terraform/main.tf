# SSH key pair for EC2 access
resource "aws_key_pair" "app" {
  key_name   = var.key_pair_name
  public_key = file("~/.ssh/${var.key_pair_name}.pub")
}

# IAM role for EC2 — allows EC2 to access AWS services without credentials
resource "aws_iam_role" "app" {
  name = "url-shortener-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach CloudWatch policy to EC2 role — allows sending logs to CloudWatch
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Instance profile — wrapper around IAM role, EC2 only accepts roles through this
resource "aws_iam_instance_profile" "app" {
  name = "url-shortener-instance-profile"
  role = aws_iam_role.app.name
}

# EC2 instance — runs our application
resource "aws_instance" "app" {
  ami                    = "ami-0df7a207adb9748c7" # Ubuntu 22.04 Singapore
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.app.name
  key_name               = aws_key_pair.app.key_name

  # Script that runs on first boot — installs Docker
  user_data = <<-EOF
    #!/bin/bash
    apt-get update && apt-get install -y docker.io
    systemctl enable --now docker
    usermod -aG docker ubuntu
  EOF

  tags = { Name = "url-shortener-app" }
}

# RDS PostgreSQL instance — our database in private subnet
resource "aws_db_instance" "postgres" {
  identifier        = "url-shortener-db"
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "urldb"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]

  skip_final_snapshot = true  # for learning project — no snapshot on delete
  deletion_protection = false # allows us to destroy with terraform destroy
  storage_encrypted   = true  # encrypt data at rest

  tags = { Name = "url-shortener-db" }
}
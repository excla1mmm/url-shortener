# Public IP of EC2 — needed for SSH and GitHub Secrets
output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app.public_ip
}

# EC2 public DNS — alternative way to connect
output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.app.public_dns
}

# RDS endpoint — needed for DATABASE_URL in the app
output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.postgres.endpoint
}

# RDS database name
output "rds_db_name" {
  description = "Database name"
  value       = aws_db_instance.postgres.db_name
}
variable "key_pair_name" {
  description = "SSH key pair name for EC2"
  type        = string
}

variable "db_username" {
  description = "PostgreSQL username"
  type        = string
  default     = "urluser"
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "my_ip" {
  description = "Your IP address for SSH access"
  type        = string
}
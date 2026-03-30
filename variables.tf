variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
  default     = "sulaimon"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "my_ip" {
  description = "Your public IP address for SSH access (e.g., 1.2.3.4/32)"
  type        = string
}

variable "instance_type_web" {
  description = "Instance type for web servers"
  type        = string
  default     = "t3.micro"
}

variable "instance_type_db" {
  description = "Instance type for DB server"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "web_admin_password" {
  description = "Password for the ec2-user on web servers"
  type        = string
  sensitive   = true
}

variable "db_admin_password" {
  description = "Password for the ec2-user on the database server"
  type        = string
  sensitive   = true
}
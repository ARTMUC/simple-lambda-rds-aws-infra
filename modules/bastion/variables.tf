variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (test, prod)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for bastion"
  type        = string
  default     = "t2.micro"
}

# variable "public_subnet_id" {
#   description = "Public subnet ID for bastion"
#   type        = string
# }

variable "private_subnet_id" {
  description = "Private subnet ID for bastion"
  type = string
}

variable "security_group_id" {
  description = "Security group ID for bastion"
  type        = string
}
variable "region" {
  description = "aws region"
  type = string
}
variable "project_name" {
  description = "project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

variable ami {
  type        = map(string)
  description = "AMI id's based on region"
}

variable "roles" {
  description = "type of servers needed"
  type = list(string)
}

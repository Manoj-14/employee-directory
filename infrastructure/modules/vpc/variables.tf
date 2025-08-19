variable "project_name" {
  description = "project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "availability_zones" {
  type        = list(string)
  description = "CIDR block for VPC"
}

variable "private_subnet_cidrs" {
  description = "list of CIDR's for private subnets"
  type = list(string)
}

variable "public_subnet_cidrs" {
  description = "list of CIDR's for public subnets"
  type = list(string)
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

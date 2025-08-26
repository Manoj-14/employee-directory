variable "region" {
  description = "region"
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
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "list of CIDR's for public subnets"
  type        = list(string)
}

variable "ami" {
  type        = map(string)
  description = "AMI id's based on region"
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

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

variable "roles" {
  description = "type of servers needed"
  type        = list(string)
}

variable "secret_name" {
  description = "name of the secret in secret manager"
  type        = string
}

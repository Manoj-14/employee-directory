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

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}

# variable "region" {
#   description = "AWS region to deploy resources"
#   type        = string
# }

# variable "subnet_ids" {
#   description = "List of subnet IDs for the EKS cluster"
#   type        = list(string)
# }

variable "node_groups" {
  description = "Map of node group configurations"
  type        = map(object({
    instance_types   = list(string)
    capacity_type   = string
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
  }))
}

variable "iam_devops_user_arn" {
  description = "arn of the devops user iam"
  type = string
}

variable "iam_cluster_role_arn" {
  description = "arn of the iam cluster role"
  type = string
}


variable "iam_node_role_arn" {
  description = "arn of the iam node role"
  type = string
}

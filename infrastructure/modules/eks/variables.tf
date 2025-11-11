variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}
variable "project_name" {
  description = "value for the project name tag"
  type = string 
}
variable "environment" {
  description = "value for the environment tag"
  type = string
}
variable "vpc_id" {
  description = "The VPC ID where the EKS cluster will be deployed"
  type        = string  
}
variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

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

variable "tags" {
  description = "value for the tags"
  type        = map(string)
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
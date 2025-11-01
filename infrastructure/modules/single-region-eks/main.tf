terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

module "vpc" {
  source               = "../vpc"
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = var.tags
}

module "eks" {
  source             = "../eks"
  project_name       = var.project_name
  environment        = var.environment
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  iam_cluster_role_arn = var.iam_cluster_role_arn
  iam_node_role_arn = var.iam_node_role_arn
  iam_devops_user_arn = var.iam_devops_user_arn
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnets
  node_groups        = var.node_groups
  tags               = var.tags
}
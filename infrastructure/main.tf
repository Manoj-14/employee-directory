provider "aws" {
  region = var.region.global
}

provider "aws" {
  region = var.region.primary_region
  alias  = "primary_region"
}

provider "aws" {
  region = var.region.secondary_region
  alias  = "secondary_region"
}

module "primary_region_eks" {
  source = "./modules/single-region-eks"

  providers = {
    aws = aws.primary_region
  }

  project_name         = var.project_name
  environment          = terraform.workspace
  vpc_cidr             = lookup(var.vpc_cidr, var.region.primary_region, null)
  availability_zones   = lookup(var.availability_zones, var.region.primary_region, [])
  public_subnet_cidrs  = lookup(var.public_subnet_cidrs, var.region.primary_region, [])
  private_subnet_cidrs = lookup(var.private_subnet_cidrs, var.region.primary_region, [])
  cluster_name         = var.cluster_name
  cluster_version      = var.cluster_version
  iam_cluster_role_arn = aws_iam_role.cluster-role.arn
  iam_node_role_arn    = aws_iam_role.node-role.arn
  iam_devops_user_arn  = data.aws_iam_user.devops.arn
  node_groups          = lookup(var.node_groups, terraform.workspace, {})
  tags                 = { "project-name" : var.project_name, "environment" : terraform.workspace, "region" : var.region.primary_region }
}

module "helm_primary_region" {
  source = "./modules/helm"

  cluster_name             = module.primary_region_eks.cluster_name
  cluster_endpoint         = module.primary_region_eks.cluster_endpoint
  cluster_certificate_data = module.primary_region_eks.cluster_certificate_data
}

module "secondary_region_eks" {
  source = "./modules/single-region-eks"

  providers = {
    aws = aws.secondary_region
  }

  project_name         = var.project_name
  environment          = terraform.workspace
  vpc_cidr             = lookup(var.vpc_cidr, var.region.secondary_region, null)
  availability_zones   = lookup(var.availability_zones, var.region.secondary_region, [])
  public_subnet_cidrs  = lookup(var.public_subnet_cidrs, var.region.secondary_region, [])
  private_subnet_cidrs = lookup(var.private_subnet_cidrs, var.region.secondary_region, [])
  cluster_name         = var.cluster_name
  cluster_version      = var.cluster_version
  iam_cluster_role_arn = aws_iam_role.cluster-role.arn
  iam_node_role_arn    = aws_iam_role.node-role.arn
  iam_devops_user_arn  = data.aws_iam_user.devops.arn
  node_groups          = lookup(var.node_groups, terraform.workspace, {})
  tags                 = { "project-name" : var.project_name, "environment" : terraform.workspace, "region" : var.region.secondary_region }
}

module "helm_secondary_region" {
  source = "./modules/helm"

  cluster_name             = module.secondary_region_eks.cluster_name
  cluster_endpoint         = module.secondary_region_eks.cluster_endpoint
  cluster_certificate_data = module.secondary_region_eks.cluster_certificate_data

}

# module "vpc" {
#   source               = "./modules/vpc"
#   project_name         = var.project_name
#   environment          = var.environment
#   vpc_cidr             = var.vpc_cidr
#   availability_zones   = var.availability_zones
#   public_subnet_cidrs  = var.public_subnet_cidrs
#   private_subnet_cidrs = var.private_subnet_cidrs
#   tags                 = var.tags
# }

# module "bastion" {
#   source = "./modules/bastion"

#   region              = var.region
#   project_name        = var.project_name
#   environment         = terraform.workspace
#   instance_type       = var.instance_type
#   ami                 = var.ami
#   vpc_id              = module.vpc.vpc_id
#   public_subnet_cidrs = module.vpc.public_subnets
#   key_pair_name       = module.ec2.key_pair_name
#   tags                = var.tags
# }

# module "ec2" {
#   source = "./modules/ec2"

#   region                    = var.region
#   project_name              = var.project_name
#   environment               = terraform.workspace
#   instance_type             = var.instance_type
#   key_name                  = var.key_name
#   ami                       = var.ami
#   vpc_id                    = module.vpc.vpc_id
#   public_subnet_cidrs       = module.vpc.public_subnets
#   private_subnet_cidrs      = module.vpc.private_subnets
#   bastion_security_group_id = module.bastion.bastion_security_group_id
#   roles                     = var.roles
#   tags                      = var.tags
# }

# module "eks" {
#   source             = "./modules/eks"
#   region             = var.region
#   project_name       = var.project_name
#   environment        = terraform.workspace
#   cluster_name       = var.cluster_name
#   cluster_version    = var.cluster_version
#   cluster_policies   = var.cluster_policys
#   node_policies      = var.node_policies
#   devops_username    = var.devops_username
#   developer_username = var.developer_username
#   vpc_id             = module.vpc.vpc_id
#   subnet_ids         = module.vpc.private_subnets
#   node_groups        = lookup(var.node_groups, terraform.workspace)
#   tags               = { "project-name" : var.project_name, "environment" : terraform.workspace }
#   depends_on         = [module.vpc]
# }

# # resource "local_file" "ansible_inventory" {
# #   filename             = "${path.module}/../ansible/inventory.ini"
# #   file_permission      = "0644"
# #   directory_permission = "0755"

# #   content = <<EOT
# #     server ansible_host=${module.ec2.public_ip}

# #     [servers]
# #     server

# #     [servers:vars]
# #     ansible_user=ec2-user
# #     ansible_ssh_private_key_file=emp-dir-key.pem
# #     ansible_ssh_common_args='-o StrictHostKeyChecking=no'
# #     EOT
# # }

# resource "local_file" "ansible_inventory" {
#   content = templatefile("${path.module}/inventory.tftpl", {
#     server_groups          = local.ansible_inventory_groups
#     bastion_host_public_ip = module.bastion.public_ip
#     key_file_name          = "${module.ec2.key_pair_name}.pem"
#   })
#   filename = "${path.module}/../ansible/inventory.ini"
# }

# resource "null_resource" "local_kubeconfig_setup" {
#   provisioner "local-exec" {
#     command = <<EOT
#       aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}
#     EOT
#   }
# }
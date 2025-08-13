terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    key          = "terraform.tf.state"
    region       = "us-east-1"
    use_lockfile = "true"
    encrypt      = true
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source               = "./modules/vpc"
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = var.tags
}

module "ec2" {
  source = "./modules/ec2"

  region              = var.region
  project_name        = var.project_name
  environment         = var.environment
  instance_type       = var.instance_type
  key_name            = var.key_name
  ami                 = var.ami
  vpc_id              = module.vpc.vpc_id
  public_subnet_cidrs = module.vpc.public_subnets
  tags                = var.tags
}

resource "local_file" "ansible_inventory" {
  filename             = "${path.module}/../ansible/inventory.ini"
  file_permission      = "0644"
  directory_permission = "0755"

  content = <<EOT
    server ansible_host=${module.ec2.public_ip}

    [servers]
    server

    [servers:vars]
    ansible_user=ec2-user
    ansible_ssh_private_key_file=emp-dir-key.pem
    ansible_ssh_common_args='-o StrictHostKeyChecking=no'
    EOT
}

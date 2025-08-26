output "proxy_public_ip" {
  description = "Public ip of the server"
  value       = module.ec2.public_ip
}

output "bastion_public_ip" {
  description = "Public ip of the bastion"
  value       = module.bastion.public_ip
}

output "vpc_id" {
  description = "vpc id"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "public subnets cidr"
  value       = module.vpc.public_subnets
}

# output "ansible_inventory_file" {
#   description = "file contents"
#   value       = module.ec2.ansible_inventory_file
# }

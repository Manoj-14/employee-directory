output "server_public_ip" {
  description = "Public ip of the server"
  value       = module.ec2.public_ip
}

output "vpc_id" {
  description = "vpc id"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "public subnets cidr"
  value       = module.vpc.public_subnets
}

output "private_key" {
  description = "private key"
  value       = module.ec2.private_key_pem
  sensitive   = true
}

output "ansible_inventory_file" {
  description = "file contents"
  value       = module.ec2.ansible_inventory_file
}

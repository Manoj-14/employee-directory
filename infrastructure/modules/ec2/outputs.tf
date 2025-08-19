output public_ip {
  description = "public ip"
  value =  aws_instance.server[*].public_ip
}

output "private_key_pem" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "instances" {
  description = "instance ip and roles"
  value = [for inst in aws_instance.server : {public_ip = inst.public_ip , tags = inst.tags}]
}

output "ansible_inventory_file" {
  description="anisble inventory file"
  value = {
    for role in distinct([for inst in aws_instance.server : inst.tags.Role]) : role=>[for inst in aws_instance.server : inst.public_ip if inst.tags.Role == role]
  }
}

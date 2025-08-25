output public_ip {
  description = "public ip of servers"
  value =  aws_instance.proxy-server.public_ip
}

output "proxy_data" {
  description = "proxy ip and roles"
  value = {
    ip = aws_instance.proxy-server.public_ip,
    tags = aws_instance.proxy-server.tags
  }
}

output "servers_data" {
  description = "other servers ip and roles"
  value = [for inst in aws_instance.web-server : {ip = inst.private_ip , tags = inst.tags}]
}
# output "ansible_inventory_file" {
#   description="anisble inventory file"
#   value = {
#     for role in distinct([for inst in aws_instance.proxy-server : inst.tags.Role]) : role=>[for inst in aws_instance.proxy-server : inst.ip if inst.tags.Role == role]
#   }
# }

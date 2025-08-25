output bastion_security_group_id {
  value       = aws_security_group.bastion-sg.id
  description = "bastion sg"
}

output "bastion_data" {
  description = "bastion ip and roles"
  value = {
    ip = aws_instance.bastion-server.public_ip,
    tags = aws_instance.bastion-server.tags
  }
}

output "public_ip" {
    description = "Public Ip"
    value = aws_instance.bastion-server.public_ip
}

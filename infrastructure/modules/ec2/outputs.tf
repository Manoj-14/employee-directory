output public_ip {
  description = "public ip"
  value =  aws_instance.server.public_ip
}

region = "ap-southeast-2"
ami = {
  ap-southeast-2 = "ami-0a0b0b06dd1636865"
  us-east-2      = "ami-0a887e401f7654935"
}
project_name  = "employee-directory"
environment   = "dev"
instance_type = "t2.micro"
key_name      = "emp-dir-key"
roles         = ["proxy-server", "web-server"]
tags = {
  project = "employee-directory"
}
secret_name = "instance-secret-1"

vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["ap-southeast-2a", "ap-southeast-2b"]
public_subnet_cidrs  = ["10.0.1.0/24"]
private_subnet_cidrs = []

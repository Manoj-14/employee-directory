region = "us-east-1"
ami = {
  us-east-1 = "ami-0de716d6197524dd9"
  us-east-2 = "ami-0a887e401f7654935"
}
project_name  = "employee-directory"
environment   = "dev"
instance_type = "t2.micro"
key_name      = "emp-dir-key"
tags = {
  project = "employee-directory"
}

vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24"]
private_subnet_cidrs = []

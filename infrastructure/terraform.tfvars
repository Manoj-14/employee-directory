region = {
  global           = "ap-southeast-2",
  primary_region   = "ap-south-1"
  secondary_region = "us-west-1"
}
ami = {
  ap-southeast-2 = "ami-0a0b0b06dd1636865"
  us-east-2      = "ami-0a887e401f7654935"
}
project_name = "employee-directory"
# environment   = "dev"
instance_type = "t2.micro"
key_name      = "emp-dir-key"
roles         = ["web-1", "web-2"]
tags = {
  project = "employee-directory"
}
secret_name = "instance-secret-2"


vpc_cidr = {
  ap-southeast-2 = "10.0.0.0/16"
  ap-south-1     = "20.0.0.0/16",
  us-west-1      = "30.0.0.0/16"
}
availability_zones = {
  ap-southeast-2 = ["ap-southeast-2a", "ap-southeast-2b"],
  ap-south-1     = ["ap-south-1a", "ap-south-1b"],
  us-west-1      = ["us-west-1a", "us-west-1c"]
}
public_subnet_cidrs = {
  ap-southeast-2 = ["10.0.1.0/24", "10.0.2.0/24"]
  ap-south-1     = ["20.0.1.0/24", "20.0.2.0/24"],
  us-west-1      = ["30.0.1.0/24", "30.0.2.0/24"],
}
private_subnet_cidrs = {
  ap-southeast-2 = ["10.0.3.0/24", "10.0.4.0/24"]
  ap-south-1     = ["20.0.3.0/24", "20.0.4.0/24"],
  us-west-1      = ["30.0.3.0/24", "30.0.4.0/24"],
}
cluster_name    = "employee-directory"
cluster_version = "1.30"
node_groups = {
  "stage" = {
    "general" = {
      instance_types = ["c7i-flex.large"]
      capacity_type  = "ON_DEMAND"
      scaling_config = {
        desired_size = 2
        max_size     = 4
        min_size     = 1
      }
    }
  }
  "production" = {
    "general" = {
      instance_types = ["m7i-flex.large"]
      capacity_type  = "ON_DEMAND"
      scaling_config = {
        desired_size = 3
        max_size     = 6
        min_size     = 2
      }
    }
  }
}
developer_username = "developer-user"
devops_username    = "manm-win"

cluster_policies = [
  "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
  "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
]
node_policies = [
  "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
  "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
]
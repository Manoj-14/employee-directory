resource "aws_vpc" "vpc"{
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  enable_dns_support = "true"
  tags = merge(var.tags,{
        Name = "${var.project_name}-${var.environment}-vpc"
    })
}

resource "aws_subnet" "subnet-pub" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = "true"
  availability_zone = var.availability_zones[count.index]
  tags = merge(var.tags,{
        Name = "${var.project_name}-${var.environment}-pub-sub"
    })
}

resource "aws_subnet" "subnet-priv" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = merge(var.tags,{
        Name = "${var.project_name}-${var.environment}-pub-sub"
    })
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(var.tags,{
        Name = "${var.project_name}-${var.environment}-igw"
    })
}


# resource "aws_eip" "nat_eip" {
#   count = length(var.public_subnet_cidrs)
#   domain = "vpc"
#   tags = {
#     "Name": "vprofile_nat_eip"
#   }
# }

# resource "aws_nat_gateway" "nat" {
#   count = length(var.public_subnet_cidrs)
#   allocation_id = aws_eip.nat_eip[count.index].id
#   subnet_id = aws_subnet.subnet-pub[count.index].id
#   tags = {
#     "Name": "vprofile_nat"
#   }
# }

resource "aws_route_table" "pub-RT" {
  vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.IGW.id
    }

    tags = merge(var.tags,{
        Name = "${var.project_name}-${var.environment}-pub-rt"
    })
}

# resource "aws_route_table" "priv-RT" {
#   count = length(var.private_subnet_cidrs)
#   vpc_id = aws_vpc.vpc.id

#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_nat_gateway.nat[count.index].id
#     }

#     tags = {
#       "Name" = "vprofile-priv-RT"
#     }
# }

resource "aws_route_table_association" "subnet_public_rt" {
  count = length(var.public_subnet_cidrs)
  subnet_id = aws_subnet.subnet-pub[count.index].id
  route_table_id = aws_route_table.pub-RT.id
}


# resource "aws_route_table_association" "subnet_private_rt" {
#   count = length(var.private_subnet_cidrs)
#   subnet_id = aws_subnet.subnet-priv[count.index].id
#   route_table_id = aws_route_table.priv-RT[count.index].id
# }

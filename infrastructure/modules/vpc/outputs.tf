output "vpc_id" {
    description = "VPC ID"
    value       = aws_vpc.vpc.id
}

output "public_subnets" {
    description = "Public subnets"
    value = aws_subnet.subnet-pub[*].id
}

output "private_subnets" {
    description = "Private subnets"
    value = aws_subnet.subnet-priv[*].id
}

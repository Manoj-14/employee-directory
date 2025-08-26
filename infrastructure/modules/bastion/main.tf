# resource "tls_private_key" "ssh_key_bastion" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "key-bastion" {
#     key_name = "bastion-key"
#     public_key = tls_private_key.ssh_key_bastion.public_key_openssh

#     tags = merge(var.tags,{
#         Name = "${var.project_name}-${var.environment}-key-pair-bastion"
#     })
# }

# resource "local_sensitive_file" "bastion_private_key" {
#     content = tls_private_key.ssh_key_bastion.private_key_pem
#     filename = "${path.module}/../../../ansible/bastion.pem"

#     provisioner "local-exec" {
#         command = "chmod 400 ${path.module}/../../../ansible/bastion.pem"
#     }

# }

# module "bastion-secrets"{
#     source ="../secrets"

#     project_name = var.project_name
#     environment = var.environment
#     secret_name = "bastion-secret-1"
#     secret_string = tls_private_key.ssh_key_bastion.private_key_pem
# }


resource "aws_security_group" "bastion-sg" {
    name_prefix = "${var.project_name}-${var.environment}-bastion-sg"
    vpc_id = var.vpc_id

    ingress {
        description = "SSH"
        from_port = 22
        to_port=22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress{
        description = "All traffic"
        from_port=0
        to_port=0
        protocol="-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags,{
        Name = "${var.project_name}-${var.environment}-proxy-sg"
    })
}

resource "aws_instance" "bastion-server" {
    ami = var.ami[var.region]
    instance_type=var.instance_type
    key_name = var.key_pair_name
    vpc_security_group_ids = [aws_security_group.bastion-sg.id]
    subnet_id = var.public_subnet_cidrs[0]
    tags = merge(var.tags,{
        Name = "${var.project_name}-${var.environment}-server-bastion"
        Role = "bastion"
    })
}

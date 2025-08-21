resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key" {
    key_name = var.key_name
    public_key = tls_private_key.ssh_key.public_key_openssh

    tags = merge(var.tags,{
        Name = "${var.project_name}-${var.environment}-key-pair"
    })
}

# resource "local_sensitive_file" "private_key" {
#     content = tls_private_key.ssh_key.private_key_pem
#     filename = "${path.module}/../../../ansible/${var.key_name}.pem"

#     provisioner "local-exec" {
#         command = "chmod 400 ${path.module}/../../../ansible/${var.key_name}.pem"
#     }

# }

resource "aws_security_group" "flask-sg" {
    name_prefix = "${var.project_name}-${var.environment}-flask-"
    vpc_id = var.vpc_id

    ingress {
        description = "SSH"
        from_port = 22
        to_port=22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTP"
        from_port = 80
        to_port=80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTPS"
        from_port = 443
        to_port=443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "APP dev server"
        from_port = 5000
        to_port=5000
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
        Name = "${var.project_name}-${var.environment}-sg"
    })
}

resource "aws_instance" "server" {
    count = length(var.roles)
    ami = var.ami[var.region]
    instance_type=var.instance_type
    key_name = aws_key_pair.key.key_name
    vpc_security_group_ids = [aws_security_group.flask-sg.id]
    subnet_id = var.public_subnet_cidrs[0]
    tags = merge(var.tags,{
        Name = "${var.project_name}-${var.environment}-server-${count.index}"
        Role = var.roles[count.index]
    })
}

# resource "tls_private_key" "ssh_key_proxy" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "key-proxy" {
#     key_name = "proxy-key"
#     public_key = tls_private_key.ssh_key_proxy.public_key_openssh

#     tags = merge(var.tags,{
#         Name = "${var.project_name}-${var.environment}-key-pair-proxy"
#     })
# }

# module "proxy-secrets"{
#     source ="../secrets"

#     project_name = var.project_name
#     environment = var.environment
#     secret_name = "proxy-secret-1"
#     secret_string = tls_private_key.ssh_key_proxy.private_key_pem
# }

# resource "tls_private_key" "ssh_key_web" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "key-web" {
#     key_name = "web-key"
#     public_key = tls_private_key.ssh_key_web.public_key_openssh

#     tags = merge(var.tags,{
#         Name = "${var.project_name}-${var.environment}-key-pair-web"
#     })
# }

# module "web-secrets"{
#     source ="../secrets"

#     project_name = var.project_name
#     environment = var.environment
#     secret_name = "web-secret-1"
#     secret_string = tls_private_key.ssh_key_web.private_key_pem
# }


# resource "local_sensitive_file" "web_private_key" {
#     content = tls_private_key.ssh_key_web.private_key_pem
#     filename = "${path.module}/../../../ansible/web.pem"

#     provisioner "local-exec" {
#         command = "chmod 400 ${path.module}/../../../ansible/web.pem"
#     }

# }

# resource "local_sensitive_file" "proxy_private_key" {
#     content = tls_private_key.ssh_key_proxy.private_key_pem
#     filename = "${path.module}/../../../ansible/proxy.pem"

#     provisioner "local-exec" {
#         command = "chmod 400 ${path.module}/../../../ansible/proxy.pem"
#     }

# }

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key" {
    key_name = "emp-dir-key"
    public_key = tls_private_key.ssh_key.public_key_openssh

    tags = merge(var.tags,{
        Name = "${var.project_name}-${var.environment}-key-pair"
    })
}

module "proxy-secrets"{
    source ="../secrets"

    project_name = var.project_name
    environment = var.environment
    secret_name = "${aws_key_pair.key.key_name}-1"
    secret_string = tls_private_key.ssh_key.private_key_pem
}

resource "local_sensitive_file" "proxy_private_key" {
    content = tls_private_key.ssh_key.private_key_pem
    filename = "${path.module}/../../../ansible/${aws_key_pair.key.key_name}.pem"

    provisioner "local-exec" {
        command = "chmod 400 ${path.module}/../../../ansible/${aws_key_pair.key.key_name}.pem"
    }

}

resource "aws_security_group" "proxy-sg" {
    name_prefix = "${var.project_name}-${var.environment}-proxy-sg"
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

resource "aws_security_group" "web-sg" {
    name_prefix = "${var.project_name}-${var.environment}-web-sg"
    vpc_id = var.vpc_id


    ingress {
        description = "HTTPS"
        from_port = 443
        to_port=443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTPS"
        from_port = 5000
        to_port=5000
        protocol = "tcp"
        security_groups = [aws_security_group.proxy-sg.id]
    }

    ingress {
        description = "SSH"
        from_port = 22
        to_port=22
        protocol = "tcp"
        security_groups = [var.bastion_security_group_id]
    }

    egress{
        description = "All traffic"
        from_port=0
        to_port=0
        protocol="-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.tags,{
        Name = "${var.project_name}-${var.environment}-web-sg"
    })
}

resource "aws_instance" "proxy-server" {
    ami = var.ami[var.region]
    instance_type=var.instance_type
    key_name = aws_key_pair.key.key_name
    vpc_security_group_ids = [aws_security_group.proxy-sg.id]
    subnet_id = var.public_subnet_cidrs[0]
    tags = merge(var.tags,{
        Name = "${var.project_name}-${var.environment}-proxy-server"
        Role = "proxy"
    })
}

resource "aws_instance" "web-server" {
    for_each = toset(var.roles)
    ami = var.ami[var.region]
    instance_type=var.instance_type
    key_name = aws_key_pair.key.key_name
    vpc_security_group_ids = [aws_security_group.web-sg.id]
    subnet_id = var.private_subnet_cidrs[0]
    tags = merge(var.tags,{
        Name = "${var.project_name}-${var.environment}-${each.value}-server"
        Role = regex("^([^-]+)",each.value)[0]
    })
}

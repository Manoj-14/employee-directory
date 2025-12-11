terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "helm" {
  kubernetes = {
    host = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args = ["eks", "get-token", "--cluster-name",var.cluster_name]
      command = "aws"
    }
  }
}

resource "helm_release" "ingress-nginx" {
  name = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  namespace = "ingress-nginx"
  create_namespace = true

  set = [ {
    name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  },
  {
      name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
      value = "true"
  },
  {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-additional-resource-tags"
    value = "Environment=${terraform.workspace},Project=${var.project_name},ManagedBy=Terraform"
  }]
}

data "aws_lb" "aws_lb" {
  depends_on = [ helm_release.ingress-nginx ]

  tags = {
    "kubernetes.io/service-name" = "ingress-nginx/ingress-nginx-controller",
    "kubernetes.io/cluster/${var.project_name}" = "owned"
    "Environment"=terraform.workspace
  }
}
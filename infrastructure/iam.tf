data "aws_iam_user" "devops" {
  user_name = var.devops_username
}

locals {
  validate_user = data.aws_iam_user.devops.arn != "" ? true : file("ERROR: DevOps user ${var.devops_username} not found")
}


resource "aws_iam_role" "cluster-role" {
  name = "${var.project_name}-${terraform.workspace}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster-policy" {
  for_each   = toset(var.cluster_policies)
  policy_arn = each.value
  role       = aws_iam_role.cluster-role.name
}


resource "aws_iam_role" "node-role" {
  name = "${var.project_name}-${terraform.workspace}-eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node-policy" {
  for_each   = toset(var.node_policies)
  policy_arn = each.value
  role       = aws_iam_role.node-role.name
}

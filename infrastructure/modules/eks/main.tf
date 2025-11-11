resource "aws_eks_cluster" "cluster" {
  name = var.cluster_name
  version = var.cluster_version
  role_arn = var.iam_cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  access_config {
    authentication_mode = "API"
  }

  tags = merge(var.tags,{
    name = "${var.project_name}-${var.environment}-eks-cluster"
  })
}

resource "aws_eks_access_entry" "devops_entry" {
  cluster_name = aws_eks_cluster.cluster.name
  principal_arn = var.iam_devops_user_arn
  kubernetes_groups = [ "eks-admin" ]
  type = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks-cluster-admin-policy-association" {
    cluster_name = aws_eks_cluster.cluster.name
    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    access_scope {
      type = "cluster"
    }
    principal_arn = var.iam_devops_user_arn
    depends_on = [ aws_eks_access_entry.devops_entry ]
}

resource "aws_eks_node_group" "node-group" {
  for_each = var.node_groups
  cluster_name = aws_eks_cluster.cluster.name
  node_group_name = each.key
  node_role_arn = var.iam_node_role_arn
  subnet_ids = var.subnet_ids

  instance_types = each.value.instance_types
  capacity_type = each.value.capacity_type
  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  tags = merge(var.tags,{
    name = "${var.project_name}-${var.environment}-eks-node-group-${each.key}"
  })
}
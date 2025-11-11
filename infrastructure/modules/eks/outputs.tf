output "cluster_name" {
  description = "value of the EKS cluster name"
    value       = aws_eks_cluster.cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
    value       = aws_eks_cluster.cluster.endpoint
}

output "cluster_certificate_data" {
  description = "eks cluster ca certificate data"
  value = aws_eks_cluster.cluster.certificate_authority.0.data
}
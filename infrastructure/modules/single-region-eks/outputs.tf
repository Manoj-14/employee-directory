output "cluster_endpoint" {
  description = "eks cluster endpoint"
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "eks cluster name"
  value = module.eks.cluster_name
}

output "cluster_certificate_data" {
  description = "eks cluster certificate data"
  value = module.eks.cluster_certificate_data
}
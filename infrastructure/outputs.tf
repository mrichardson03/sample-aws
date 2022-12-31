output "cluster_name" {
  description = "Name of created EKS cluster."
  value       = module.eks.cluster_id
}

output "mongodb_instance" {
  description = "Public IP address of created MongoDB instance."
  value       = module.mongodb_instance.public_ip
}

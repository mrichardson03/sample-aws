output "cluster_name" {
  value = module.eks.cluster_name
}

output "mongodb_instance" {
  value = module.mongodb_instance.public_ip
}

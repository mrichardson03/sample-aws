output "mongodb_instance" {
  value = module.mongodb_instance.public_ip
}

output "jenkins_password_command" {
  value = "kubectl exec --namespace default -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo"
}

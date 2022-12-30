output "jenkins_password_command" {
  description = "Shell command to retrieve Jenkins admin password."
  value       = "kubectl exec --namespace default -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo"
}

variable "aws_region" {
  description = "AWS region to create resources in."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name to deploy resources on."
  type        = string
  default     = "sample-aws-eks-cluster"
}

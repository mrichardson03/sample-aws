variable "key_name" {
  description = "SSH key used to authenticate to the created instances."
  type        = string
}

variable "env_name" {
  description = "String prefix for names of created resources."
  type        = string
  default     = "sample-aws"
}

variable "mgmt_cidrs" {
  description = "List of CIDR prefixes to allow in created security groups."
  type        = list(any)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Map of tags added to created resources."
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "sample-aws"
    Owner       = "Your-Name-SE"
  }
}

variable "aws_region" {
  description = "AWS region to create resources in."
  type        = string
  default     = "us-east-1"
}

variable "ubuntu_1604_ami" {
  description = "AMI ID for Ubuntu 16.04 in us-east-1.  Used to create MongoDB instance."
  type        = string
  default     = "ami-099e921e69356cf89"
}

variable "create_budget" {
  description = "Whether to create a budget for cost monitoring."
  type        = bool
  default     = true
}

variable "budget_name" {
  description = "Name of created budget."
  type        = string
  default     = "Monthly Budget"
}

variable "budget_amount" {
  description = "Amount to monitor in created budget."
  type        = string
  default     = "120"
}

variable "budget_currency" {
  description = "Currency for created budget."
  type        = string
  default     = "USD"
}

variable "budget_time_unit" {
  description = "Time unit for created budget."
  type        = string
  default     = "MONTHLY"
}

variable "budget_email" {
  description = "Email address to send budget alerts to."
  type        = string
  default     = "your@email.com"
}

variable "key_name" {
  type = string
}

variable "env_name" {
  default = "sample-aws"
}

variable "mgmt_cidrs" {
  type    = list(any)
  default = ["0.0.0.0/0"]
}

variable "tags" {
  default = {
    Terraform   = "true"
    Environment = "sample-aws"
    Owner       = "Your-Name-SE"
  }
}

variable "aws_region" {
  default = "us-east-1"
}

# aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20201210"
variable "ubuntu_1604_ami" {
  default = "ami-099e921e69356cf89"
}

variable "create_budget" {
  default = true
}

variable "budget_name" {
  default = "Monthly Budget"
}

variable "budget_amount" {
  default = "120"
}

variable "budget_currency" {
  default = "USD"
}

variable "budget_time_unit" {
  default = "MONTHLY"
}

variable "budget_email" {
  default = "your@email.com"
}

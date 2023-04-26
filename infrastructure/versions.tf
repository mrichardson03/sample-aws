terraform {
  required_version = ">=0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.64.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
    # time = {
    #   source  = "hashicorp/time"
    #   version = "~> 0.9.0"
    # }
  }
}

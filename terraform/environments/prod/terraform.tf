terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "ozawakosuke-aboutme-tfstate"
    key     = "prod/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}

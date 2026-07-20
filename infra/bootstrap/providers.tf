provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "aboutme"
      ManagedBy = "terraform"
      Component = "bootstrap"
    }
  }
}

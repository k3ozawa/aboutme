variable "aws_region" {
  description = "AWS region for the existing Terraform state bucket and KMS key"
  type        = string
  default     = "ap-northeast-1"
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the CI role, in owner/repo format"
  type        = string
  default     = "k3ozawa/aboutme"

  validation {
    condition     = can(regex("^[^/]+/[^/]+$", var.github_repository))
    error_message = "github_repository must be in owner/repo format."
  }
}

variable "state_bucket_name" {
  description = "Name of the existing S3 bucket holding Terraform remote state"
  type        = string
  default     = "k3ozawa-tf-backend"
}

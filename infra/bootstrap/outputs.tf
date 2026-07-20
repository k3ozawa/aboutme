output "state_bucket_name" {
  description = "Name of the existing S3 bucket holding Terraform remote state"
  value       = var.state_bucket_name
}

output "kms_key_arn" {
  description = "ARN of the KMS key used by sops"
  value       = aws_kms_key.shared.arn
}

output "kms_key_id" {
  description = "Key ID of the shared KMS key"
  value       = aws_kms_key.shared.key_id
}

output "github_actions_role_arn" {
  description = "IAM role ARN GitHub Actions assumes via OIDC to run Terraform/sops"
  value       = aws_iam_role.github_actions.arn
}

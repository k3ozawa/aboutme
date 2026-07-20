terraform {
  # Values supplied via `terraform init -backend-config=backend.hcl`
  # (see backend.hcl.example). The existing bucket is configured outside
  # Terraform so this root does not attempt to create or modify it.
  backend "s3" {}
}

terraform {
  # Values supplied via `terraform init -backend-config=backend.hcl`
  # (see backend.hcl.example). Left empty here since the bucket name is
  # decided at infra/bootstrap apply time, not hardcoded in source.
  backend "s3" {}
}

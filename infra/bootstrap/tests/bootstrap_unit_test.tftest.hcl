# Unit tests using mock providers: verify Terraform wiring/logic without real
# AWS credentials. Assertions are limited to explicitly-configured arguments
# (mocking cannot fabricate realistic computed values such as generated IAM
# policy JSON, so those are left to manual review instead of asserted here).

mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

mock_provider "tls" {
  mock_data "tls_certificate" {
    defaults = {
      certificates = [
        {
          sha1_fingerprint = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        },
      ]
    }
  }
}

variables {
  aws_region        = "ap-northeast-1"
  github_repository = "k3ozawa/aboutme"
  state_bucket_name = "aboutme-terraform-state-test"
}

run "state_bucket_configured" {
  command = plan

  assert {
    condition     = aws_s3_bucket.terraform_state.bucket == var.state_bucket_name
    error_message = "State bucket name should match the state_bucket_name variable"
  }
}

run "state_bucket_versioning_enabled" {
  command = plan

  assert {
    condition     = aws_s3_bucket_versioning.terraform_state.versioning_configuration[0].status == "Enabled"
    error_message = "State bucket versioning should be enabled"
  }
}

run "state_bucket_encrypted_with_shared_kms_key" {
  command = plan

  assert {
    condition = anytrue([
      for rule in aws_s3_bucket_server_side_encryption_configuration.terraform_state.rule :
      rule.apply_server_side_encryption_by_default[0].sse_algorithm == "aws:kms"
    ])
    error_message = "State bucket must use SSE-KMS encryption"
  }

  assert {
    condition = anytrue([
      for rule in aws_s3_bucket_server_side_encryption_configuration.terraform_state.rule :
      rule.bucket_key_enabled == true
    ])
    error_message = "S3 bucket key should be enabled to reduce KMS request cost"
  }
}

run "state_bucket_fully_blocks_public_access" {
  command = plan

  assert {
    condition = alltrue([
      aws_s3_bucket_public_access_block.terraform_state.block_public_acls,
      aws_s3_bucket_public_access_block.terraform_state.block_public_policy,
      aws_s3_bucket_public_access_block.terraform_state.ignore_public_acls,
      aws_s3_bucket_public_access_block.terraform_state.restrict_public_buckets,
    ])
    error_message = "State bucket must block all forms of public access"
  }
}

run "shared_kms_key_has_rotation_enabled" {
  command = plan

  assert {
    condition     = aws_kms_key.shared.enable_key_rotation == true
    error_message = "Shared KMS key should have automatic rotation enabled"
  }

  assert {
    condition     = aws_kms_alias.shared.name == "alias/aboutme-terraform"
    error_message = "KMS alias should be predictable for sops/.sops.yaml configuration"
  }
}

run "github_oidc_provider_scoped_to_github_actions" {
  command = plan

  assert {
    condition     = aws_iam_openid_connect_provider.github_actions.url == "https://token.actions.githubusercontent.com"
    error_message = "OIDC provider must point at GitHub Actions' issuer"
  }

  assert {
    condition     = tolist(aws_iam_openid_connect_provider.github_actions.client_id_list) == tolist(["sts.amazonaws.com"])
    error_message = "OIDC provider audience must be sts.amazonaws.com"
  }
}

run "github_actions_role_named_predictably" {
  command = plan

  assert {
    condition     = aws_iam_role.github_actions.name == "aboutme-github-actions"
    error_message = "GitHub Actions role name should be stable for CI configuration"
  }
}

run "rejects_malformed_github_repository" {
  command = plan

  variables {
    github_repository = "not-a-valid-repo-slug"
  }

  expect_failures = [
    var.github_repository,
  ]
}

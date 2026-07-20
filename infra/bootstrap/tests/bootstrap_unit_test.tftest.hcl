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

  mock_data "aws_iam_openid_connect_provider" {
    defaults = {
      arn            = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
      url            = "https://token.actions.githubusercontent.com"
      client_id_list = ["sts.amazonaws.com"]
    }
  }
}

variables {
  aws_region        = "ap-northeast-1"
  github_repository = "k3ozawa/aboutme"
  state_bucket_name = "k3ozawa-tf-backend"
}

run "existing_state_bucket_is_exposed" {
  command = plan

  assert {
    condition     = output.state_bucket_name == "k3ozawa-tf-backend"
    error_message = "The existing state bucket name should be exposed unchanged"
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

run "existing_github_oidc_provider_is_reused" {
  command = plan

  assert {
    condition     = data.aws_iam_openid_connect_provider.github_actions.url == "https://token.actions.githubusercontent.com"
    error_message = "The existing GitHub Actions OIDC provider should be looked up by issuer URL"
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

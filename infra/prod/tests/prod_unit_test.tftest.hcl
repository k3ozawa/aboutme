# Mocks both providers so this test needs neither real AWS/sops decryption
# nor a real Vercel API token.
mock_provider "sops" {
  mock_data "sops_file" {
    defaults = {
      data = {
        vercel_api_token = "mock-vercel-api-token"
      }
    }
  }
}

mock_provider "vercel" {
  mock_resource "vercel_project" {
    defaults = {
      id = "prj_mock123"
    }
  }

  mock_resource "vercel_project_domain" {
    defaults = {
      id = "domain_mock123"
    }
  }
}

variables {
  project_name      = "aboutme-test"
  github_repository = "k3ozawa/aboutme"
}

run "domain_output_reflects_custom_domain" {
  command = plan

  variables {
    custom_domain = "example.com"
  }

  # project_id isn't asserted here: it's a mocked-computed Vercel attribute
  # that only resolves to a known value within the module's own test scope
  # (see infra/modules/vercel-container-site/tests), not through a root
  # module output during `plan`. The domain output below is a direct
  # pass-through of a variable, so it stays known at plan time and is a
  # meaningful check that the root module wires custom_domain through.
  assert {
    condition     = output.domain == "example.com"
    error_message = "domain output should reflect the configured custom_domain"
  }
}

run "no_domain_output_by_default" {
  command = plan

  assert {
    condition     = output.domain == null
    error_message = "domain output should be null when custom_domain is empty"
  }
}

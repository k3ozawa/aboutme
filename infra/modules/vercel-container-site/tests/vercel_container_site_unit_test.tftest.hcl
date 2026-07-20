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

  mock_resource "vercel_project_environment_variable" {
    defaults = {
      id = "env_mock123"
    }
  }
}

variables {
  project_name   = "aboutme"
  git_repository = "k3ozawa/aboutme"
}

run "project_wires_name_and_repository" {
  command = plan

  assert {
    condition     = vercel_project.this.name == "aboutme"
    error_message = "Project name should match project_name variable"
  }

  assert {
    condition     = vercel_project.this.git_repository.repo == "k3ozawa/aboutme"
    error_message = "git_repository.repo should match git_repository variable"
  }

  assert {
    condition     = vercel_project.this.git_repository.type == "github"
    error_message = "git_repository.type should be github"
  }
}

run "no_domain_created_when_custom_domain_is_empty" {
  command = plan

  assert {
    condition     = length(vercel_project_domain.this) == 0
    error_message = "No domain resource should be created when custom_domain is empty"
  }

  assert {
    condition     = output.domain == null
    error_message = "domain output should be null when custom_domain is empty"
  }
}

run "domain_created_when_custom_domain_set" {
  command = plan

  variables {
    custom_domain = "example.com"
  }

  assert {
    condition     = length(vercel_project_domain.this) == 1
    error_message = "A domain resource should be created when custom_domain is set"
  }

  assert {
    condition     = vercel_project_domain.this[0].domain == "example.com"
    error_message = "Domain resource should use the custom_domain value"
  }
}

run "no_environment_variables_by_default" {
  command = plan

  assert {
    condition     = length(vercel_project_environment_variable.this) == 0
    error_message = "No environment variables should be created by default"
  }
}

run "environment_variables_created_from_map" {
  command = plan

  variables {
    environment_variables = {
      EXAMPLE_KEY = {
        value  = "example-value"
        target = ["production"]
      }
    }
  }

  assert {
    condition     = length(vercel_project_environment_variable.this) == 1
    error_message = "Exactly one environment variable resource should be created"
  }

  assert {
    condition     = vercel_project_environment_variable.this["EXAMPLE_KEY"].value == "example-value"
    error_message = "Environment variable value should match the input map"
  }

  assert {
    condition     = tolist(vercel_project_environment_variable.this["EXAMPLE_KEY"].target) == tolist(["production"])
    error_message = "Environment variable target should match the input map"
  }
}

run "rejects_malformed_git_repository" {
  command = plan

  variables {
    git_repository = "not-a-valid-repo-slug"
  }

  expect_failures = [
    var.git_repository,
  ]
}

resource "vercel_project" "this" {
  name = var.project_name

  git_repository = {
    type = "github"
    repo = var.git_repository
  }
}

resource "vercel_project_domain" "this" {
  count = var.custom_domain != "" ? 1 : 0

  project_id = vercel_project.this.id
  domain     = var.custom_domain
}

# for_each requires non-sensitive keys even when the whole map is marked
# sensitive; the variable names themselves aren't secret, only their values.
locals {
  environment_variable_keys = nonsensitive(keys(var.environment_variables))
}

resource "vercel_project_environment_variable" "this" {
  for_each = toset(local.environment_variable_keys)

  project_id = vercel_project.this.id
  key        = each.key
  value      = var.environment_variables[each.key].value
  target     = var.environment_variables[each.key].target
  sensitive  = true
}

data "sops_file" "secrets" {
  source_file = "${path.module}/../../secrets/prod.enc.yaml"
}

module "aboutme_site" {
  source = "../modules/vercel-container-site"

  project_name   = var.project_name
  git_repository = var.github_repository
  custom_domain  = var.custom_domain
}

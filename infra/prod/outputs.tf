output "project_id" {
  description = "Vercel project ID"
  value       = module.aboutme_site.project_id
}

output "domain" {
  description = "Custom domain attached to the project, or null if none was configured"
  value       = module.aboutme_site.domain
}

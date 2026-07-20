output "project_id" {
  description = "Vercel project ID"
  value       = vercel_project.this.id
}

output "domain" {
  description = "Custom domain attached to the project, or null if none was configured"
  value       = var.custom_domain != "" ? vercel_project_domain.this[0].domain : null
}

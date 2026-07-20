variable "project_name" {
  description = "Vercel project name"
  type        = string
  default     = "aboutme"
}

variable "github_repository" {
  description = "GitHub repository connected to the Vercel project, in owner/repo format"
  type        = string
  default     = "k3ozawa/aboutme"
}

variable "custom_domain" {
  description = "Custom domain to attach to the Vercel project. Replace the placeholder once a domain is chosen"
  type        = string
  default     = "example.com"
}

variable "vercel_team_id" {
  description = "Vercel team ID to deploy into. Leave empty to use the personal account"
  type        = string
  default     = ""
}

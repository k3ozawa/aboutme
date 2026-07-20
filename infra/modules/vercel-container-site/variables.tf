variable "project_name" {
  description = "Vercel project name"
  type        = string
}

variable "git_repository" {
  description = "GitHub repository connected to the project, in owner/repo format"
  type        = string

  validation {
    condition     = can(regex("^[^/]+/[^/]+$", var.git_repository))
    error_message = "git_repository must be in owner/repo format."
  }
}

variable "custom_domain" {
  description = "Custom domain to attach to the project. Empty string skips domain creation"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Vercel project environment variables, keyed by variable name. Values are typically sourced from a sops-decrypted secrets file"
  type = map(object({
    value  = string
    target = list(string)
  }))
  default   = {}
  sensitive = true
}

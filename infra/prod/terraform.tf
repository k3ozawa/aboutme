terraform {
  required_version = ">= 1.11"

  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 5.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}

provider "vercel" {
  api_token = data.sops_file.secrets.data["vercel_api_token"]
  team      = var.vercel_team_id != "" ? var.vercel_team_id : null
}

terraform {
  cloud {
    organization = "dotcomrow"

    workspaces {
      name = var.project
    }
  }
}
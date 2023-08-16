terraform {
  cloud {
    organization = "dotcomrow"

    workspaces {
      name = provider.project
    }
  }
}
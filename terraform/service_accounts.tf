resource "google_service_account" "data-layer-bigquery" {
  account_id   = "data-layer-bigquery"
  display_name = "data-layer-bigquery"
}

resource "google_project_iam_binding" "data-layer-bigquery" {
  project = var.project
  role    = "roles/bigquery.editor"
  members = [
    "serviceAccount:${google_service_account.data-layer-bigquery.email}"
  ]
}
resource "google_service_account" "data-layer-bigquery" {
  account_id   = "data-layer-bigquery"
  display_name = "data-layer-bigquery"
}
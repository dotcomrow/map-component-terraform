resource "google_service_account" "data_layer_bigquery" {
  account_id   = "data_layer_bigquery"
  display_name = "data_layer_bigquery"
}
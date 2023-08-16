resource "google_bigquery_dataset" "map-component-dataset" {
  dataset_id                  = "map-component-dataset"
  description                 = "Dataset for map component project"
  location                    = "US"
}

resource "google_bigquery_table" "map-component-poi-data" {
  dataset_id = google_bigquery_dataset.map-component-dataset.dataset_id
  table_id   = "map-component-poi-data"

  schema = <<EOF
[
  {
    "name": "ID",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "POI Record ID"
  },
  {
    "name": "LOCATION",
    "type": "GEOGRAPHY",
    "mode": "REQUIRED",
    "description": "Geographic location of POI"
  },
  {
    "name": "DATA",
    "type": "JSON",
    "mode": "REQUIRED",
    "description": "Data associated with POI"
  },
  {
    "name": "ACCOUNT_ID",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Account id of POI owner"
  },
  {
    "name": "LAST_UPDATE_DATETIME",
    "type": "DATETIME",
    "mode": "REQUIRED",
    "description": "Last update datetime of POI"
  }
]
EOF
}

resource "google_bigquery_routine" "get-row-id" {
  dataset_id      = google_bigquery_dataset.map-component-dataset.dataset_id
  routine_id      = "get-row-id"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = <<-EOS
    SELECT 1 + count(ID) AS value FROM \`${google_bigquery_table.map-component-poi-data.dataset_id}.${google_bigquery_table.map-component-poi-data.table_id}\`;
  EOS
}
resource "google_bigquery_dataset" "map_component_dataset" {
  dataset_id                  = "map_component_dataset"
  description                 = "Dataset for map component project"
  location                    = "US"
}

resource "google_bigquery_table" "map_component_poi_data" {
  dataset_id = google_bigquery_dataset.map_component_dataset.dataset_id
  table_id   = "map_component_poi_data"
  deletion_protection = false

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
    "type": "RECORD",
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

resource "google_bigquery_table" "map_component_poi_data_deletes" {
  dataset_id = google_bigquery_dataset.map_component_dataset.dataset_id
  table_id   = "map_component_poi_data_deletes"
  deletion_protection = false

  schema = <<EOF
[
  {
    "name": "ID",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "POI Record ID to delete"
  },
  {
    "name": "ACCOUNT_ID",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Account id of POI owner"
  },
  {
    "name": "REQUESTED_ON",
    "type": "DATETIME",
    "mode": "REQUIRED",
    "description": "Delete request datetime POI"
  },
  {
    "name": "DELETE_AFTER",
    "type": "DATETIME",
    "mode": "REQUIRED",
    "description": "Delete after time"
  }
]
EOF
}

resource "google_bigquery_table" "poi_seq" {
  dataset_id = google_bigquery_dataset.map_component_dataset.dataset_id
  table_id   = "POI_SEQ"
  deletion_protection = false

  schema = <<EOF
[
  {
    "name": "seq_name",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "sequence name"
  },
  {
    "name": "poi_seq",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "ID sequence for POI"
  }
]
EOF
}

resource "google_bigquery_routine" "get_row_id" {
  dataset_id      = google_bigquery_dataset.map_component_dataset.dataset_id
  routine_id      = "get_row_id"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = <<-EOS
    UPDATE `${google_bigquery_table.poi_seq.dataset_id}.${google_bigquery_table.poi_seq.table_id}` SET poi_seq = poi_seq + 1 WHERE seq_name = 'POI_SEQ';
    SELECT poi_seq AS value FROM `${google_bigquery_table.poi_seq.dataset_id}.${google_bigquery_table.poi_seq.table_id}` WHERE seq_name = 'POI_SEQ';
  EOS
}

resource "google_bigquery_routine" "delete_record_from_delay_table" {
  dataset_id      = google_bigquery_dataset.map_component_dataset.dataset_id
  routine_id      = "delete_record_from_delay_table"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = <<-EOS
    DELETE FROM `${google_bigquery_table.map_component_poi_data.dataset_id}.${google_bigquery_table.map_component_poi_data.table_id}` WHERE ID = record_id AND ACCOUNT_ID = account_id;
    DELETE FROM `${google_bigquery_table.map_component_poi_data_deletes.dataset_id}.${google_bigquery_table.map_component_poi_data_deletes.table_id}` WHERE ID = record_id AND ACCOUNT_ID = account_id;
  EOS
  arguments {
    name          = "account_id"
    argument_kind = "ANY_TYPE"
    mode = "IN"
  }
  arguments {
    name          = "record_id"
    argument_kind = "ANY_TYPE"
    mode = "IN"
  }
}
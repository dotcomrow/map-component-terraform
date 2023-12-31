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
    "type": "STRING",
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

resource "google_bigquery_table" "sequences" {
  dataset_id = google_bigquery_dataset.map_component_dataset.dataset_id
  table_id   = "sequences"
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
    "name": "seq_value",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "sequence value"
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
    DECLARE seq int64;
    DECLARE max_id int64;

    set seq = (SELECT seq_value FROM `global_config_dataset.sequences` WHERE seq_name = 'POI_SEQ');
    set max_id = (SELECT max(id) FROM `global_config_dataset.lookup_codes`);

    IF seq IS NULL THEN
      INSERT INTO `global_config_dataset.sequences` (seq_name, seq_value) VALUES ('POI_SEQ', max_id);
    ELSE
      UPDATE `global_config_dataset.sequences` SET seq_value = seq_value + 1 WHERE seq_name = 'POI_SEQ';
    END IF;

    SELECT seq_value FROM `global_config_dataset.sequences` WHERE seq_name = 'POI_SEQ';
  EOS
}

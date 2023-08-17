resource "google_cloud_tasks_queue" "map-data-delete-queue" {
  name = "map-data-delete-queue"
  location = "us-east1"
}
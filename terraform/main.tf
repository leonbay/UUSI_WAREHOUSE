terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = var.credentials_file
  
  project = var.project
  region = var.region
  zone = var.zone
}

provider "google-beta" {
  credentials = var.credentials_file
  
  project = var.project
  region = var.region
  zone = var.zone
}

# references child, which was needed to get outputs for the sql - vm connection

module "child"{
  source = ".//child"
  project = var.project
  user_name = var.user_name
  credentials_file = var.credentials_file
}

resource "google_secret_manager_secret" "sql-password2" {
  provider = google-beta

  secret_id = "sql-password2"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "sql-password2" {
  provider = google-beta

  secret      = google_secret_manager_secret.sql-password2.id
  secret_data = module.child.generated_user_password
}

resource "google_secret_manager_secret" "sql-username2" {
  provider = google-beta

  secret_id = "sql-username2"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "sql-username2" {
  provider = google-beta

  secret      = google_secret_manager_secret.sql-username2.id
  secret_data = module.child.user_name
}

resource "google_secret_manager_secret" "sql-ipv42" {
  provider = google-beta

  secret_id = "sql-ipv42"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "sql-ipv42" {
  provider = google-beta

  secret      = google_secret_manager_secret.sql-ipv42.id
  secret_data = module.child.instance_address
}


resource "google_cloud_scheduler_job" "job" {
  name             = "delete_carts"
  description      = "test http job"
  schedule         = "0 1 * * *"
  time_zone        = "Europe/Helsinki"
  

  http_target {
    http_method = "GET"
    uri         = module.child.function_url
  }
}

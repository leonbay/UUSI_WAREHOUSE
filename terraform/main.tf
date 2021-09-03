terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  #credentials = var.credentials_file
  
  project = var.project
  region = var.region
  zone = var.zone
}

provider "google-beta" {
  #credentials = var.credentials_file
  
  project = var.project
  region = var.region
  zone = var.zone
}

# references child, which was needed to get outputs for the sql - vm connection

module "child"{
  source = ".//child"
  project = var.project
  user_name = var.user_name
  #credentials_file = var.credentials_file
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

resource "google_secret_manager_secret" "sql-user2" {
  provider = google-beta

  secret_id = "sql-user2"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "sql-user2" {
  provider = google-beta

  secret      = google_secret_manager_secret.sql-user2.id
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
  name             = var.scheduler_name
  description      = var.scheduler_description
  schedule         = var.schedule
  time_zone        = var.time_zone
  

  http_target {
    http_method = var.http_method
    uri         = module.child.function_url
  }
}


resource "google_api_gateway_api" "piirakka" {
  provider = google-beta
  api_id   = "piirakka"
}

resource "google_api_gateway_api_config" "api-config2" {
  provider      = google-beta
  api           = "piirakka"
  api_config_id = "api-config2"
  depends_on = [google_api_gateway_api.piirakka]

  openapi_documents {
    document {
      path     = var.path
      contents = filebase64(var.contents_file)
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "api-gw-gw" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.api-config2.id
  gateway_id = "api-gw-gw"
}
resource "google_storage_bucket" "bucket1" {
  name = "demotaampas"
}

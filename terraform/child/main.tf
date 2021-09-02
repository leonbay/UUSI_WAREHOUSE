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


# enabled ips

locals {
onprem = ["0.0.0.0/0"]
}

# makes cloud sql instance

resource "google_sql_database_instance" "master" {
  name = var.master_instance_name
  database_version = var.database_version
  region = var.region
  settings {
    tier = var.tier
    disk_size = var.disk_size
    disk_type = var.disk_type
    availability_type = var.availability_type
    activation_policy = var.activation_policy
    ip_configuration {

      ipv4_enabled = true
        
        dynamic "authorized_networks" {
          for_each = local.onprem
          iterator = onprem

        content {
          name  = "onprem-${onprem.key}"
          value = onprem.value
        }
      }
    }
  }
}

# makes cloud sql database

resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.master.name
}

# needed to randomize password

resource "random_id" "user-password" {
  byte_length = 8
}

# makes sql user

resource "google_sql_user" "default" {
  name     = var.user_name
  instance = google_sql_database_instance.master.name
  host     = var.user_host
  password = var.user_password == "" ? random_id.user-password.hex : var.user_password
}

resource "google_storage_bucket" "bucket" {
  name = var.bucket_name
}

resource "google_storage_bucket_object" "archive" {
  name   = var.zip_name
  bucket = google_storage_bucket.bucket.name
  source = var.zip_source
}

resource "google_cloudfunctions_function" "function" {
  name        = var.function_name
  description = var.function_description
  runtime     = var.runtime
  service_account_email = var.saccount

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = var.fentrypoint
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = var.finvoker
  member = var.member
}
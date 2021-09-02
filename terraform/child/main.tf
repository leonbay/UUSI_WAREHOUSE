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

#add_to_cart funktio:
resource "google_storage_bucket_object" "archive2" {
  name   = var.zip_name2
  bucket = google_storage_bucket.bucket.name
  source = var.zip_source2
}

resource "google_cloudfunctions_function" "function2" {
  name        = var.function_name2
  description = var.function_description2
  runtime     = var.runtime
  service_account_email = var.saccount

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive2.name
  trigger_http          = true
  entry_point           = var.fentrypoint2
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker2" {
  project        = google_cloudfunctions_function.function2.project
  region         = google_cloudfunctions_function.function2.region
  cloud_function = google_cloudfunctions_function.function2.name

  role   = var.finvoker
  member = var.member
}

#remove_one_from_cart funktio:
resource "google_storage_bucket_object" "archive3" {
  name   = var.zip_name3
  bucket = google_storage_bucket.bucket.name
  source = var.zip_source3
}

resource "google_cloudfunctions_function" "function3" {
  name        = var.function_name3
  description = var.function_description3
  runtime     = var.runtime
  service_account_email = var.saccount

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive3.name
  trigger_http          = true
  entry_point           = var.fentrypoint3
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker3" {
  project        = google_cloudfunctions_function.function3.project
  region         = google_cloudfunctions_function.function3.region
  cloud_function = google_cloudfunctions_function.function3.name

  role   = var.finvoker
  member = var.member
}

#add tables to database:
resource "google_storage_bucket_object" "archive8" {
  name   = var.zip_name8
  bucket = google_storage_bucket.bucket.name
  source = var.zip_source8
}

resource "google_cloudfunctions_function" "function8" {
  name        = var.function_name8
  description = var.function_description8
  runtime     = var.runtime
  service_account_email = var.saccount

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive8.name
  trigger_http          = true
  entry_point           = var.fentrypoint8
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker8" {
  project        = google_cloudfunctions_function.function8.project
  region         = google_cloudfunctions_function.function8.region
  cloud_function = google_cloudfunctions_function.function8.name

  role   = var.finvoker
  member = var.member
}

#populate tables in database:
resource "google_storage_bucket_object" "archive9" {
  name   = var.zip_name9
  bucket = google_storage_bucket.bucket.name
  source = var.zip_source9
}

resource "google_cloudfunctions_function" "function9" {
  name        = var.function_name9
  description = var.function_description9
  runtime     = var.runtime
  service_account_email = var.saccount

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive9.name
  trigger_http          = true
  entry_point           = var.fentrypoint9
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker9" {
  project        = google_cloudfunctions_function.function9.project
  region         = google_cloudfunctions_function.function9.region
  cloud_function = google_cloudfunctions_function.function9.name

  role   = var.finvoker
  member = var.member
}
terraform {
  backend "gcs" {
    bucket = "gcppy-319110-tfstate"
  }
}
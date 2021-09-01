variable "project" { }

variable "credentials_file" { }

variable "region" {
  description = "Region for cloud resources"
  default     = "us-central1"
}

variable "zone" {
  description = "Zone for cloud resources"
  default     = "us-central1-c"
}
variable "user_name" { }
variable "project" {
 default     = "gcppy-319110"
 }

variable "region" {
  description = "Region for cloud resources"
  default     = "us-central1"
}

variable "zone" {
  description = "Zone for cloud resources"
  default     = "us-central1-c"
}
variable "user_name" {
 default     = "postgres"
 }

 variable "scheduler_name" {
 default     = "delete_carts"
 }

  variable "scheduler_description" {
 default     = "test http job"
 }

   variable "schedule" {
 default     = "0 * * * *"
 }
   variable "time_zone" {
 default     = "Europe/Helsinki"
 } 

    variable "http_method" {
 default     = "GET"
 } 
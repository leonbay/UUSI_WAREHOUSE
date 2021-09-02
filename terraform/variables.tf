variable "project" {
 default     = "axial-canto-324606"
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


variable "contents_file" {
  default = "./finalwebstoreapigateway.yaml"
}

variable "path" {
  default = "finalwebstoreapigateway.yaml"
} 
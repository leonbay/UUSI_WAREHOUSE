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

variable "database_version" {
  description = "The version of of the database."
  default     = "POSTGRES_13"
}

variable "master_instance_name" {
  description = "The name of the master instance to replicate"
  default     = "prodjuukeli"
}

variable "tier" {
  description = "db machine tier"
  default     = "db-f1-micro"
}

variable "db_name" {
  description = "Name of the default database to create"
  default     = "piirakka"
}

variable "user_name" { }

variable "user_host" {
  description = "The host for the default user."
  default     = ""
}

variable "user_password" {
  description = "The password for the default user. If not set, a random one will be generated and available in the generated_user_password output variable."
  default     = ""
}

variable "activation_policy" {
  description = "This specifies when the instance should be active. Can be either `ALWAYS`, `NEVER` or `ON_DEMAND`."
  default     = "ALWAYS"
}

variable "disk_size" {
  description = "Second generation only. The size of data disk, in GB. Size of a running instance cannot be reduced but can be increased."
  default     = 10
}

variable "disk_type" {
  description = "Second generation only. The type of data disk: `PD_SSD` or `PD_HDD`."
  default     = "PD_HDD"
}

variable "availability_type" {
  description = "This specifies whether a PostgreSQL instance should be set up for high availability (REGIONAL) or single zone (ZONAL)."
  default     = "ZONAL"
}
variable "bucket_name" {
  description = "bucket's name."
  default     = "delete_old_carts"
}
#henkan funktio
variable "zip_name" {
  description = "zip's name."
  default     = "delete_old_cart.zip"
}

variable "zip_source" {
  description = "zip's source."
  default     = "./child/functions/delete_old_cart.zip"
}
variable "function_name" {
  description = "function name."
  default     = "poistoa"
}
variable "function_description" {
  description = "function description."
  default     = "poistoa"
}

variable "runtime" {
  description = "function runtime."
  default     = "python37"
}

variable "saccount" {
  description = "service account."
  default     = "terraformer@axial-canto-324606.iam.gserviceaccount.com"
}

variable "fentrypoint" {
  description = "entrypoint"
  default     = "poistoa"
}
variable "finvoker" {
  description = "invoker"
  default     = "roles/cloudfunctions.invoker"
}

variable "member" {
  description = "memeber"
  default     = "allUsers"
}

#add_to_cart funktion variables:
variable "zip_name2" {
  description = "zip's name."
  default     = "add_to_cart.zip"
}

variable "zip_source2" {
  description = "zip's source."
  default     = "./child/functions/add_to_cart.zip"
}
variable "function_name2" {
  description = "function name."
  default     = "add_to_cart"
}
variable "function_description2" {
  description = "function description."
  default     = "adds to cart, removes from storage"
}

variable "fentrypoint2" {
  description = "entrypoint"
  default     = "add_to_cart"
}


#remove_one_from_cart variables:
variable "zip_name3" {
  description = "zip's name."
  default     = "remove_one_from_cart.zip"
}

variable "zip_source3" {
  description = "zip's source."
  default     = "./child/functions/remove_one_from_cart.zip"
}
variable "function_name3" {
  description = "function name."
  default     = "remove_one_from_cart"
}
variable "function_description3" {
  description = "function description."
  default     = "removes one from cart, adds one to storage"
}

variable "fentrypoint3" {
  description = "entrypoint"
  default     = "remove_one_from_cart"
}

#fetch_all_products variables:
variable "zip_name4" {
  description = "zip's name."
  default     = "fetch_all_products.zip"
}

variable "zip_source4" {
  description = "zip's source."
  default     = "./child/functions/fetch_all_products.zip"
}
variable "function_name4" {
  description = "function name."
  default     = "fetch_all_products"
}
variable "function_description4" {
  description = "function description."
  default     = "returns all products"
}

variable "fentrypoint4" {
  description = "entrypoint"
  default     = "connect"
}

#final_order variables:
variable "zip_name5" {
  description = "zip's name."
  default     = "final_order.zip"
}

variable "zip_source5" {
  description = "zip's source."
  default     = "./child/functions/final_order.zip"
}
variable "function_name5" {
  description = "function name."
  default     = "make new order"
}
variable "function_description5" {
  description = "function description."
  default     = "Makes new final order"
}

variable "fentrypoint5" {
  description = "entrypoint"
  default     = "get_order"
}
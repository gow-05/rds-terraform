variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "db_name" {
  type    = string
  default = "storedb"
}

variable "db_username" {
  type    = string
  default = "storeuser"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "rails_master_key" {
  type      = string
  sensitive = true
}

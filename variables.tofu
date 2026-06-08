variable "timeweb_token" {
  type = string
  sensitive = true
  description = "Timeweb API token"
}

variable "rke2_token" {
  description = "RKE2 cluster token"
  type = string
  sensitive = true
}

variable "ssl_privkey" {
  description = "SSL private key"
  type = string
  sensitive = true
}

variable "ssl_fullchain" {
  description = "SSL fullchain"
  type = string
  sensitive = false
}

variable "availability_zone" {
  description = "Timeweb Cloud availability zone"
  type = string
  default = "spb-3"
}
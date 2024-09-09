terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = "~> 1"
    }
  }
}

provider "boundary" {
  addr                   = var.boundary_address
  #auth_method_id         = var.service_account_authmethod_id
  #auth_method_login_name = var.service_account_name
  #auth_method_password   = var.service_account_password
}

provider "vault" {
}
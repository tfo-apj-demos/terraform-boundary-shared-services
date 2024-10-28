variable "boundary_address" {
  type = string
}

variable "vault_address" {
  type        = string
  description = "Address of the Vault server for credential management."
  default     = ""
}

variable "hosts" {
  type        = list(string)
  description = "List of FQDNs for the hosts."
  default     = []
}


/*variable "service_account_authmethod_id" {
  type = string
}

variable "service_account_name" {
  type = string
}

variable "service_account_password" {
  type = string
}*/

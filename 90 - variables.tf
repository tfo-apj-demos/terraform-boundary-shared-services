variable "vault_address" {
  type        = string
  description = "Address of the Vault server for credential management."
}

variable "hosts" {
  type        = list(string)
  description = "List of FQDNs for the hosts."
}

variable "vcenter_server_target" {
  type        = list(string)
  description = "Enable vCenter Server target."
}

variable "nsx_server_target" {
  type        = list(string)
  description = "Enable NSX Server target."
}

variable "windows_remote_desktop_target" {
  type        = list(string)
  description = "Enable Remote Desktop target."
}

variable "vault_server_target" {
  type        = list(string)
  description = "Enable Vault Server target."
}

variable "aap_server_target" {
  type        = list(string)
  description = "Enable AAP Server target."
}

variable "boundary_address" {
  type = string
}

variable "service_account_authmethod_id" {
  type = string
}

variable "service_account_name" {
  type = string
}

variable "service_account_password" {
  type = string
}
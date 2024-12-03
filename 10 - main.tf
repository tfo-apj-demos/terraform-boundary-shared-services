# Generate a Vault token for use in Boundary with a 2-hour renewal period.
# The token is used with policies for reading LDAP credentials and revoking leases.
resource "vault_token" "this" {
  no_parent = true
  period    = "2h"
  policies = [
    "ldap_reader", # Policy to read LDAP credentials
    "revoke_lease" # Policy to revoke leases
  ]
}

module "vault_server_target" {
  source  = "app.terraform.io/tfo-apj-demos/target/boundary"
  version = "3.0.0"

  project_name = "shared_services"
  target_name  = "Vault Server Access"
  hosts        = var.vault_server_target
  port         = 8200
  target_type  = "tcp"

  # Vault credential configurations
  use_credentials = false

  # Alias name for accessing the GCVE Vault
  alias_name = var.vault_server_target[0]
}

module "vcenter_target" {
  source  = "app.terraform.io/tfo-apj-demos/target/boundary"
  version = "3.0.0"

  project_name = "shared_services"
  target_name  = "vCenter Server Access"
  hosts        = var.vcenter_server_target
  port         = 443
  target_type  = "tcp"

  # Vault credential configurations
  use_credentials        = true
  credential_store_token = vault_token.this.client_token
  vault_address = "https://${var.vault_server_target[0]}:8200"
  credential_source      = "vault"
  credential_path        = "ldap/creds/vsphere_access"

  # Alias name for accessing the vCenter
  alias_name = var.vcenter_server_target[0]
}

module "nsx_server_target" {
  source  = "app.terraform.io/tfo-apj-demos/target/boundary"
  version = "3.0.0"

  project_name = "shared_services"
  target_name  = "NSX Server Access"
  hosts        = var.nsx_server_target
  port         = 443
  target_type  = "tcp"

  # Vault credential configurations
  use_credentials = false

  # Alias name for accessing the GCVE Vault
  alias_name = var.nsx_server_target[0]
}

module "windows_remote_desktop_target" {
  source  = "app.terraform.io/tfo-apj-demos/target/boundary"
  version = "3.0.0"

  project_name = "shared_services"
  target_name  = "Windows Remote Desktop Server"
  hosts        = var.windows_remote_desktop_target
  port         = 3389
  target_type  = "tcp"

  # Vault credential configurations
  use_credentials        = true
  credential_store_token = vault_token.this.client_token
  vault_address = "https://${var.vault_server_target[0]}:8200"
  credential_source      = "vault"
  credential_path        = "ldap/creds/vault_ldap_dynamic_demo_role"
  # Reference the existing credential store from vCenter target since it's already created 
  # and you can't have multiple credential stores for the same Boundary Project
  existing_credential_store_id = module.vcenter_target.credential_store_id

  # Alias name matching one of the Windows servers or a primary address for access
  alias_name = var.windows_remote_desktop_target[0]
}

module "aap_target" {
  source  = "app.terraform.io/tfo-apj-demos/target/boundary"
  version = "3.0.0"

  project_name = "shared_services"
  target_name  = "Ansible Automation Platform"
  hosts        = var.aap_server_target
  port         = 443
  target_type  = "tcp"

  # Vault credential configurations
  use_credentials = false

  # Alias name for accessing the AAP Openshift Console
  alias_name = var.aap_server_target[0]
}

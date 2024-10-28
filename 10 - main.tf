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
  source               = "github.com/tfo-apj-demos/terraform-boundary-target-refactored"
  project_name         = "shared_services"
  target_name          = "Vault Server Access"
  hosts                = ["vault.hashicorp.local"]
  port                 = 8200
  target_type          = "tcp"
  use_credentials      = false
  target_mode          = "single"
}


# module "nsx_target" {
#   source  = "app.terraform.io/tfo-apj-demos/target/boundary"
#   version = "~> 2.0.1"

#   project_name           = "shared_services"
#   hostname_prefix        = "On-Prem VMware NSX-T Manager Console"

#   hosts = [{
#     fqdn  = "nsx-98984.fe9dbbb3.asia-southeast1.gve.goog"
#   }]

#   services = [{
#     type               = "tcp"
#     port               = 443
#     use_existing_creds = false
#     use_vault_creds    = false
#   }]
# }

# module "vcenter_target" {
#   source  = "app.terraform.io/tfo-apj-demos/target/boundary"
#   version = "~> 2.0.1"

#   project_name           = "shared_services"
#   hostname_prefix        = "On-Prem VMware vCenter Console"
#   credential_store_token = vault_token.this.client_token
#   vault_address          = "https://vault.hashicorp.local:8200"

#   hosts = [{
#     fqdn  = "vcsa-98975.fe9dbbb3.asia-southeast1.gve.goog"
#   }]

#   services = [{
#     type               = "tcp"
#     port               = 443
#     use_existing_creds = false
#     use_vault_creds    = true
#     credential_path    = "ldap/creds/vsphere_access"
#   }]
# }

# module "vault_target" {
#   source  = "app.terraform.io/tfo-apj-demos/target/boundary"
#   version = "~> 2.0.1"

#   project_name    = "shared_services"
#   hostname_prefix = "On-Prem HashiCorp Vault Console"

#   hosts = [{
#     fqdn  = "vault.hashicorp.local"
#   }]

#   services = [{
#     type               = "tcp"
#     port               = 8200
#     use_existing_creds = false
#     use_vault_creds    = false
#   }]
# }
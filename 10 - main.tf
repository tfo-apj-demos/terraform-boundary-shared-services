data "boundary_scope" "org" {
  scope_id = "global"
  name     = "tfo_apj_demos"
}

data "boundary_scope" "project_scope" {
  scope_id = data.boundary_scope.org.id
  name     = "shared_services"
}

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

module "vsphere_targets" {
  source  = "app.terraform.io/tfo-apj-demos/target/boundary"
  version = "~> 1.3"

  project_name           = "shared_services"
  hostname_prefix        = "On-Prem VMware Admin"
  credential_store_token = vault_token.this.client_token
  vault_address          = "https://vault.hashicorp.local:8200"

  hosts = [{
    hostname = "VMware vCenter"
    address  = "https://vcsa-98975.fe9dbbb3.asia-southeast1.gve.goog"
    }, {
    hostname = "VMware NSX"
    address  = "https://nsx-98984.fe9dbbb3.asia-southeast1.gve.goog"
  }]

  services = [{
    type             = "tcp"
    name             = "VMware Access"
    port             = 443
    credential_paths = ["ldap/creds/vsphere_access"]
  }]
}

module "vault_target" {
  source  = "app.terraform.io/tfo-apj-demos/target/boundary"
  version = "~> 1.3"

  project_name    = "shared_services"
  hostname_prefix = "On-Prem Vault Access"

  hosts = [{
    hostname = "Vault Server"
    address  = "https://vault.hashicorp.local:8200"
  }]

  services = [{
    type             = "tcp"
    name             = "GCVE Vault Access"
    port             = 8200
  }]
}
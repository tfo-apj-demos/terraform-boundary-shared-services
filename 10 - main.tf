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

module "nsx_target" {
  source  = "app.terraform.io/tfo-apj-demos/target/boundary"
  version = "1.8.6"

  project_name           = "shared_services"
  hostname_prefix        = "On-Prem VMware NSX Admin"

  hosts = [{
    hostname = "VMware NSX"
    address  = "nsx-98984.fe9dbbb3.asia-southeast1.gve.goog"
  }]

  services = [{
    type             = "tcp"
    name             = "NSX Access"
    port             = 443
    alias            = "nsx-98984.fe9dbbb3.asia-southeast1.gve.goog"
  }]
} 

module "vcenter_target" {
  source  = "app.terraform.io/tfo-apj-demos/target/boundary"
  version = "1.8.6"

  project_name           = "shared_services"
  hostname_prefix        = "On-Prem VMware vCenter Admin"
  credential_store_token = vault_token.this.client_token
  vault_address          = "https://vault.hashicorp.local:8200"

  hosts = [{
    hostname = "VMware vCenter"
    address  = "vcsa-98975.fe9dbbb3.asia-southeast1.gve.goog"
  }]

  services = [{
    type             = "tcp"
    name             = "vCenter Access"
    port             = 443
    credential_paths = ["ldap/creds/vsphere_access"]
    alias            = "vcsa-98975.fe9dbbb3.asia-southeast1.gve.goog"
  }]
}

module "vault_target" {
  source  = "app.terraform.io/tfo-apj-demos/target/boundary"
  version = "1.8.6"

  project_name    = "shared_services"
  hostname_prefix = "On-Prem Vault"

  hosts = [{
    hostname = "Vault Server"
    address  = "vault.hashicorp.local"
  }]

  services = [{
    type             = "tcp"
    name             = "GCVE Vault Access"
    port             = 8200
    alias            = "vault.hashicorp.local"
  }]
}
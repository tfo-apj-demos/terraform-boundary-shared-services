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


module "vsphere_nsx_target" {
  source  = "app.terraform.io/tfo-apj-demos/target/boundary"
  version = "~> 1.3"

  project_name           = "shared_services"
  hostname_prefix        = "On-Prem Admin Applications"
  credential_store_token = vault_token.this.client_token
  vault_address          = "https://vault.hashicorp.local:8200"

  hosts = [{
    hostname = "VMware vCenter"
    address  = "10.10.0.6"
    }, {
    hostname = "VMware NSX"
    address  = "10.10.0.11"
  }]

  services = [{
    type             = "tcp"
    name             = "http"
    port             = 443
    credential_paths = ["ldap/creds/vsphere_access"]
  }]
}

/*module "vault_target" {
  source  = "app.terraform.io/tfo-apj-demos/target/boundary"
  version = "~> 1.2"

  project_name    = "shared_services"
  scope_id        = data.boundary_scope.project_scope.id
  hostname_prefix = "On-Prem Vault Access"

  hosts = [{
    hostname = "Vault Server"
    address  = "172.21.15.151"  # Replace with the actual Vault server IP
  }]

  services = [{
    type             = "tcp"
    name             = "vault"
    port             = 8200
  }]

  credential_store_token = vault_token.this.client_token
  vault_address          = "https://vault.hashicorp.local:8200"
}*/
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

resource "boundary_host_catalog_static" "vmware" {
  name        = "Allowed Website access (via Transparent Session)"
  description = "A set of web interfaces for VMware Admins to access."
  scope_id    = data.boundary_scope.project_scope.id
}

module "vsphere_nsx_target" {
  source  = "app.terraform.io/tfo-apj-demos/target/boundary"
  version = "~> 1.2"

  project_name    = "shared_services"
  host_catalog_id = boundary_host_catalog_static.vsphere.id
  hostname_prefix = "On-Prem Admin Applications"

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

  credential_store_token = vault_token.this.client_token
  vault_address          = "https://vault.hashicorp.local:8200"
}

resource "boundary_host_catalog_static" "security" {
  name        = "Allowed Website access (via Transparent Session)"
  description = "A set of web interfaces for Security Admins to access."
  scope_id    = data.boundary_scope.project_scope.id
}

module "vault_target" {
  source  = "app.terraform.io/tfo-apj-demos/target/boundary"
  version = "~> 1.2"

  project_name    = "shared_services"
  host_catalog_id = boundary_host_catalog_static.security.id
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
}


# resource "boundary_alias_target" "this" {
#   name                      = "example_alias_target"
#   description               = "Example alias to target foo using host boundary_host_static.bar"
#   scope_id                  = data.boundary_scope.this.id
#   value                     = "example.bar.foo.boundary"
#   destination_id            = boundary_target.foo.id
#   authorize_session_host_id = boundary_host_static.bar.id
# }
data "boundary_scope" "org" {
  scope_id = "global"
  name     = "tfo-apj-demos"
}

data "boundary_scope" "this" {
  scope_id = data.boundary_scope.org.id
  name     = "shared_services"
}

resource "boundary_host_catalog_static" "this" {
  name        = "Web UIs"
  description = "A set of web interfaces for SEs to access."
  scope_id    = data.boundary_scope.this.id
}


module "target" {
  source  = "app.terraform.io/tfo-apj-demos/target/boundary"
  version = "1.0.11-alpha"
  # insert required variables here
  project_name = "shared_services"
  host_catalog_id = boundary_host_catalog_static.this.id
  hostname_prefix = "ui"
  hosts = [{
    hostname = "vcenter"
    address = "10.10.0.6"
  },{
    hostname = "nsx"
    address = "10.10.0.11"
  }]
  services = [{
    type = "tcp"
    #name = "http"
    port = 443
    credential_paths = ["ldap/creds/vsphere_access"]
  }]
}

# resource "boundary_alias_target" "this" {
#   name                      = "example_alias_target"
#   description               = "Example alias to target foo using host boundary_host_static.bar"
#   scope_id                  = data.boundary_scope.this.id
#   value                     = "example.bar.foo.boundary"
#   destination_id            = boundary_target.foo.id
#   authorize_session_host_id = boundary_host_static.bar.id
# }
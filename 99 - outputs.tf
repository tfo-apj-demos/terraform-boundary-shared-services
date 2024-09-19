output "tcp_with_creds_target_ids" {
    value = module.vcenter_target.tcp_with_creds_target_ids
}

output "ssh_with_creds_target_ids" {
    value = module.vcenter_target.ssh_with_creds_target_ids
}

output "alias_destination_ids" {
    value = module.vcenter_target.alias_destination_ids
}

output "alias_debug_each_key" {
    value = module.vcenter_target.alias_debug_each_key
}

output "services_needing_creds_debug" {
    value = module.vcenter_target.services_needing_creds_debug
}

output "existing_infrastructure_debug" {
    value = module.vcenter_target.existing_infrastructure_debug
}

output "processed_services_debug" {
    value = module.vcenter_target.processed_services_debug
}
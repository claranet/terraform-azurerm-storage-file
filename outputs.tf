output "storage_account_properties" {
  description = "Created Storage Account properties"
  value       = module.storage_account.storage_account_properties
  sensitive   = true
}

output "storage_account_id" {
  description = "Created storage account ID"
  value       = module.storage_account.storage_account_id
}

output "storage_account_name" {
  description = "Created storage account name"
  value       = module.storage_account.storage_account_name
}

output "storage_account_identity" {
  description = "Created Storage Account identity block"
  value       = module.storage_account.storage_account_identity
}

output "storage_account_network_rules" {
  description = "Network rules of the associated Storage Account"
  value       = module.storage_account.storage_account_network_rules
}

output "storage_file_shares" {
  description = "Created file shares in the Storage Account"
  value       = module.storage_account.storage_file_shares
}

output "storage_file_shares_mount_options" {
  description = "Mount options for the file shares"
  value       = local.mount_options
}

output "default_cifs_configuration_file_path" {
  description = "Default configuration file path for CIFS credentials file"
  value       = local.cifs_creds_file_path
}

output "cifs_credentials_file_content" {
  description = "Content of the CIFS credentials file"
  value       = local.cifs_creds_file_content
  sensitive   = true
}

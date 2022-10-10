output "storage_account_properties" {
  description = "Created Storage Account properties"
  value       = module.storage_account.storage_account_properties
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

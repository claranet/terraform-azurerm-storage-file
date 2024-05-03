module "storage_account" {
  source  = "claranet/storage-account/azurerm"
  version = "~> 7.12.0"

  location       = var.location
  location_short = var.location_short
  client_name    = var.client_name
  environment    = var.environment
  stack          = var.stack

  resource_group_name = var.resource_group_name

  use_caf_naming              = var.use_caf_naming
  name_prefix                 = var.name_prefix
  name_suffix                 = var.name_suffix
  storage_account_custom_name = var.storage_account_custom_name

  logs_destinations_ids           = var.logs_destinations_ids
  logs_categories                 = var.logs_categories
  logs_metrics_categories         = var.logs_metrics_categories
  custom_diagnostic_settings_name = var.custom_diagnostic_settings_name

  account_kind             = var.is_premium ? "FileStorage" : "StorageV2"
  account_tier             = var.is_premium ? "Premium" : "Standard"
  account_replication_type = var.account_replication_type

  file_shares = var.file_shares

  file_share_cors_rules               = var.file_share_cors_rules
  file_share_retention_policy_in_days = var.file_share_retention_policy_in_days
  file_share_properties_smb           = local.smb_properties
  file_share_authentication           = var.file_share_authentication

  storage_blob_data_protection = {}
  storage_blob_cors_rules      = []

  queue_properties_logging = null

  advanced_threat_protection_enabled = var.advanced_threat_protection_enabled
  https_traffic_only_enabled = !contains([
    for s in var.file_shares : s.enabled_protocol
  ], "NFS") && var.https_traffic_only_enabled
  min_tls_version = var.min_tls_version

  network_rules_enabled   = var.network_rules_enabled
  default_firewall_action = var.default_firewall_action
  subnet_ids              = var.subnet_ids
  allowed_cidrs           = var.allowed_cidrs
  network_bypass          = var.network_bypass
  private_link_access     = var.private_link_access

  identity_ids              = var.identity_ids
  identity_type             = var.identity_type
  shared_access_key_enabled = var.shared_access_key_enabled

  default_tags_enabled = var.default_tags_enabled
  extra_tags           = var.extra_tags
}

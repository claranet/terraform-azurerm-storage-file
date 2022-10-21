data "http" "ip" {
  url = "http://ip4.clara.net/?raw"
}

module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "x.x.x"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "x.x.x"

  location    = module.azure_region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

module "logs" {
  source  = "claranet/run-common/azurerm//modules/logs"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  resource_group_name = module.rg.resource_group_name
}

module "backup" {
  source  = "claranet/run-iaas/azurerm//modules/backup"
  version = "x.x.x"

  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  logs_destinations_ids = [
    module.logs.logs_storage_account_id,
    module.logs.log_analytics_workspace_id
  ]
}

module "storage_file" {
  source  = "claranet/storage-file/azurerm"
  version = "x.x.x"

  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  account_replication_type = "LRS"

  logs_destinations_ids = [
    module.logs.logs_storage_account_id,
    module.logs.log_analytics_workspace_id
  ]

  backup_policy_id = module.backup.file_share_backup_policy_id

  allowed_cidrs  = [format("%s/32", data.http.ip.response_body)]
  network_bypass = ["AzureServices"] # Mandatory for backup purpose

  file_shares = [
    {
      name        = "share-smb"
      quota_in_gb = 500
    },
    {
      name             = "share-nfs"
      quota_in_gb      = 700
      enabled_protocol = "NFS" # Note that NFS file shares are not backed up due to Azure limitation
    }
  ]

  extra_tags = {
    foo = "bar"
  }
}

# Sample Cloud Init script that can be used in a VM or VMSS custom data
locals {
  # tflint-ignore: terraform_unused_declarations
  cloud_init_script = <<EOC
#!/bin/bash

apt install -o DPkg::Lock::Timeout=120 -y nfs-common cifs-utils

mkdir -p $(dirname ${module.storage_file.default_cifs_configuration_file_path})
echo "${module.storage_file.cifs_credentials_file_content}"  > ${module.storage_file.default_cifs_configuration_file_path}

mkdir -p ${module.storage_file.storage_file_shares_default_mount_paths["share-smb"]}
mkdir -p ${module.storage_file.storage_file_shares_default_mount_paths["share-nfs"]}

echo "${module.storage_file.storage_file_shares_default_fstab_entries["share-smb"]}" >> /etc/fstab
echo "${module.storage_file.storage_file_shares_default_fstab_entries["share-nfs"]}" >> /etc/fstab

mount ${module.storage_file.storage_file_shares_default_mount_paths["share-smb"]}
mount ${module.storage_file.storage_file_shares_default_mount_paths["share-nfs"]}}
EOC
}

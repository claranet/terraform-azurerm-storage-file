# Azure Storage Account
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/storage-file/azurerm/)

Common Azure terraform module to create a Storage Account dedicated to file shares with backup enabled.

Storage is created with Premium SKU for production ready performances.

Backup is not enabled for NFS file share due to [Azure limitation](https://learn.microsoft.com/en-us/azure/storage/files/files-nfs-protocol#support-for-azure-storage-features).

<!-- BEGIN_TF_DOCS -->
## Global versioning rule for Claranet Azure modules

| Module version | Terraform version | AzureRM version |
| -------------- | ----------------- | --------------- |
| >= 7.x.x       | 1.3.x             | >= 3.0          |
| >= 6.x.x       | 1.x               | >= 3.0          |
| >= 5.x.x       | 0.15.x            | >= 2.0          |
| >= 4.x.x       | 0.13.x / 0.14.x   | >= 2.0          |
| >= 3.x.x       | 0.12.x            | >= 2.0          |
| >= 2.x.x       | 0.12.x            | < 2.0           |
| <  2.x.x       | 0.11.x            | < 2.0           |

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) tool
which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform-wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

```hcl
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
```

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.22 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| storage\_account | git::ssh://git@git.fr.clara.net/claranet/projects/cloud/azure/terraform/modules/storage-account.git | AZ-869-share-properties |

## Resources

| Name | Type |
|------|------|
| [azurerm_backup_container_storage_account.backup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_container_storage_account) | resource |
| [azurerm_backup_protected_file_share.backup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_file_share) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_replication\_type | Defines the type of replication to use for this storage account. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS`. | `string` | `"ZRS"` | no |
| advanced\_threat\_protection\_enabled | Boolean flag which controls if advanced threat protection is enabled, see [documentation](https://docs.microsoft.com/en-us/azure/storage/common/storage-advanced-threat-protection?tabs=azure-portal) for more information. | `bool` | `false` | no |
| allowed\_cidrs | List of CIDR to allow access to that storage account. | `list(string)` | `[]` | no |
| backup\_policy\_id | ID of the Recovery Services Vault policy for file share backups. | `string` | n/a | yes |
| client\_name | Client name/account used in naming | `string` | n/a | yes |
| custom\_diagnostic\_settings\_name | Custom name of the diagnostics settings, name will be 'default' if not set. | `string` | `"default"` | no |
| default\_firewall\_action | Which default firewalling policy to apply. Valid values are `Allow` or `Deny`. | `string` | `"Deny"` | no |
| default\_tags\_enabled | Option to enable or disable default tags. | `bool` | `true` | no |
| environment | Project environment | `string` | n/a | yes |
| extra\_tags | Additional tags to associate with your Azure Container Registry. | `map(string)` | `{}` | no |
| file\_share\_cors\_rules | Storage Account file shares CORS rule. Please refer to the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#cors_rule) for more information. | <pre>object({<br>    allowed_headers    = list(string)<br>    allowed_methods    = list(string)<br>    allowed_origins    = list(string)<br>    exposed_headers    = list(string)<br>    max_age_in_seconds = number<br>  })</pre> | `null` | no |
| file\_share\_properties\_smb | Storage Account file shares smb properties. Multichannel is enabled by default on Premium Storage Accounts. | <pre>object({<br>    versions                        = optional(list(string), null)<br>    authentication_types            = optional(list(string), null)<br>    kerberos_ticket_encryption_type = optional(list(string), null)<br>    channel_encryption_type         = optional(list(string), null)<br>    multichannel_enabled            = optional(string, null)<br>  })</pre> | `null` | no |
| file\_share\_retention\_policy\_in\_days | Storage Account file shares retention policy in days. | `number` | `null` | no |
| file\_shares | List of objects to create some File Shares in this Storage Account. | <pre>list(object({<br>    name             = string<br>    quota_in_gb      = number<br>    enabled_protocol = optional(string)<br>    metadata         = optional(map(string))<br>    acl = optional(list(object({<br>      id          = string<br>      permissions = string<br>      start       = optional(string)<br>      expiry      = optional(string)<br>    })))<br>  }))</pre> | n/a | yes |
| https\_traffic\_only\_enabled | Boolean flag which forces HTTPS if enabled. Disabled if any NFS file share is provisioned. | `bool` | `true` | no |
| identity\_ids | Specifies a list of User Assigned Managed Identity IDs to be assigned to this Storage Account. | `list(string)` | `null` | no |
| identity\_type | Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both). | `string` | `"SystemAssigned"` | no |
| is\_premium | True to enable `Premium` tier for this Storage Account. | `bool` | `true` | no |
| location | Azure location | `string` | n/a | yes |
| location\_short | Short string for Azure location | `string` | n/a | yes |
| logs\_categories | Log categories to send to destinations. | `list(string)` | `null` | no |
| logs\_destinations\_ids | List of destination resources Ids for logs diagnostics destination. Can be Storage Account, Log Analytics Workspace and Event Hub. No more than one of each can be set. Empty list to disable logging. | `list(string)` | n/a | yes |
| logs\_metrics\_categories | Metrics categories to send to destinations. | `list(string)` | `null` | no |
| logs\_retention\_days | Number of days to keep logs on storage account | `number` | `30` | no |
| min\_tls\_version | The minimum supported TLS version for the storage account. Possible values are `TLS1_0`, `TLS1_1`, and `TLS1_2`. | `string` | `"TLS1_2"` | no |
| name\_prefix | Optional prefix for the generated name | `string` | `""` | no |
| name\_suffix | Optional suffix for the generated name | `string` | `""` | no |
| network\_bypass | Specifies whether traffic is bypassed for 'Logging', 'Metrics', 'AzureServices' or 'None'. | `list(string)` | <pre>[<br>  "None"<br>]</pre> | no |
| network\_rules\_enabled | Boolean to enable Network Rules on the Storage Account, requires `network_bypass`, `ip_rules`, `subnet_ids` or `default_firewall_action` correctly set if enabled. | `bool` | `true` | no |
| resource\_group\_name | Resource group name | `string` | n/a | yes |
| shared\_access\_key\_enabled | Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). | `bool` | `true` | no |
| stack | Project stack name | `string` | n/a | yes |
| storage\_account\_custom\_name | Custom Azure Storage Account name, generated if not set | `string` | `""` | no |
| subnet\_ids | Subnets to allow access to that storage account. | `list(string)` | `[]` | no |
| use\_caf\_naming | Use the Azure CAF naming provider to generate default resource name. `storage_account_custom_name` override this if set. Legacy default name is used if this is set to `false`. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| cifs\_credentials\_file\_content | Content of the CIFS credentials file |
| default\_cifs\_configuration\_file\_path | Default configuration file path for CIFS credentials file |
| storage\_account\_id | Created storage account ID |
| storage\_account\_identity | Created Storage Account identity block |
| storage\_account\_name | Created storage account name |
| storage\_account\_network\_rules | Network rules of the associated Storage Account |
| storage\_account\_properties | Created Storage Account properties |
| storage\_file\_shares | Created file shares in the Storage Account |
| storage\_file\_shares\_mount\_options | Mount options for the file shares |
<!-- END_TF_DOCS -->

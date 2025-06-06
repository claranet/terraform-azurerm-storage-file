# Azure Storage Account for file shares
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-blue.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![OpenTofu Registry](https://img.shields.io/badge/opentofu-registry-yellow.svg)](https://search.opentofu.org/module/claranet/storage-file/azurerm/)

Common Azure terraform module to create a Storage Account dedicated to file shares with backup enabled (except for NFS
due to [Azure limitation](https://learn.microsoft.com/en-us/azure/storage/files/files-nfs-protocol#support-for-azure-storage-features)).

Storage is created with Premium SKU by default for production ready performances.

<!-- BEGIN_TF_DOCS -->
## Global versioning rule for Claranet Azure modules

| Module version | Terraform version | OpenTofu version | AzureRM version |
| -------------- | ----------------- | ---------------- | --------------- |
| >= 8.x.x       | **Unverified**    | 1.8.x            | >= 4.0          |
| >= 7.x.x       | 1.3.x             |                  | >= 3.0          |
| >= 6.x.x       | 1.x               |                  | >= 3.0          |
| >= 5.x.x       | 0.15.x            |                  | >= 2.0          |
| >= 4.x.x       | 0.13.x / 0.14.x   |                  | >= 2.0          |
| >= 3.x.x       | 0.12.x            |                  | >= 2.0          |
| >= 2.x.x       | 0.12.x            |                  | < 2.0           |
| <  2.x.x       | 0.11.x            |                  | < 2.0           |

## Contributing

If you want to contribute to this repository, feel free to use our [pre-commit](https://pre-commit.com/) git hook configuration
which will help you automatically update and format some files for you by enforcing our Terraform code module best-practices.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) tool
which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform-wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

⚠️ Since modules version v8.0.0, we do not maintain/check anymore the compatibility with
[Hashicorp Terraform](https://github.com/hashicorp/terraform/). Instead, we recommend to use [OpenTofu](https://github.com/opentofu/opentofu/).

```hcl
module "storage_file" {
  source  = "claranet/storage-file/azurerm"
  version = "x.x.x"

  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.name

  account_replication_type = "LRS"

  logs_destinations_ids = [
    # module.run.logs_storage_account_id,
    # module.run.log_analytics_workspace_id
  ]

  # backup_policy_id = module.run.file_share_backup_policy_id
  backup_policy_id = null

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

  file_share_authentication = {
    directory_type = "AADDS"
  }

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

mkdir -p ${module.storage_file.file_shares_default_mount_paths["share-smb"]}
mkdir -p ${module.storage_file.file_shares_default_mount_paths["share-nfs"]}

echo "${module.storage_file.file_shares_default_fstab_entries["share-smb"]}" >> /etc/fstab
echo "${module.storage_file.file_shares_default_fstab_entries["share-nfs"]}" >> /etc/fstab

mount ${module.storage_file.file_shares_default_mount_paths["share-smb"]}
mount ${module.storage_file.file_shares_default_mount_paths["share-nfs"]}}
EOC
}
```

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.9 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| storage\_account | claranet/storage-account/azurerm | ~> 8.6.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_backup_container_storage_account.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_container_storage_account) | resource |
| [azurerm_backup_protected_file_share.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_file_share) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_replication\_type | Defines the type of replication to use for this Storage Account. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS`. | `string` | `"ZRS"` | no |
| advanced\_threat\_protection\_enabled | Boolean flag which controls if advanced threat protection is enabled, see [documentation](https://docs.microsoft.com/en-us/azure/storage/common/storage-advanced-threat-protection?tabs=azure-portal) for more information. | `bool` | `false` | no |
| allowed\_cidrs | List of CIDR to allow access to that Storage Account. | `list(string)` | `[]` | no |
| backup\_policy\_id | ID of the Recovery Services Vault policy for file share backups. | `string` | n/a | yes |
| client\_name | Client name/account used in naming. | `string` | n/a | yes |
| custom\_name | Custom Azure Storage Account name, generated if not set. | `string` | `""` | no |
| default\_firewall\_action | Which default firewalling policy to apply. Valid values are `Allow` or `Deny`. | `string` | `"Deny"` | no |
| default\_tags\_enabled | Option to enable or disable default tags. | `bool` | `true` | no |
| diagnostic\_settings\_custom\_name | Custom name of the diagnostics settings, name will be `default` if not set. | `string` | `"default"` | no |
| environment | Project environment. | `string` | n/a | yes |
| extra\_tags | Additional tags to associate with your Azure Storage Account. | `map(string)` | `{}` | no |
| file\_share\_authentication | Storage Account file shares authentication configuration. | <pre>object({<br/>    directory_type = string<br/>    active_directory = optional(object({<br/>      storage_sid         = string<br/>      domain_name         = string<br/>      domain_sid          = string<br/>      domain_guid         = string<br/>      forest_name         = string<br/>      netbios_domain_name = string<br/>    }))<br/>  })</pre> | `null` | no |
| file\_share\_cors\_rules | Storage Account file shares CORS rule. Please refer to the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#cors_rule) for more information. | <pre>object({<br/>    allowed_headers    = list(string)<br/>    allowed_methods    = list(string)<br/>    allowed_origins    = list(string)<br/>    exposed_headers    = list(string)<br/>    max_age_in_seconds = number<br/>  })</pre> | `null` | no |
| file\_share\_properties\_smb | Storage Account file shares SMB properties. Multichannel is enabled by default on Premium Storage Accounts. | <pre>object({<br/>    versions                        = optional(list(string), null)<br/>    authentication_types            = optional(list(string), null)<br/>    kerberos_ticket_encryption_type = optional(list(string), null)<br/>    channel_encryption_type         = optional(list(string), null)<br/>    multichannel_enabled            = optional(bool, null)<br/>  })</pre> | `null` | no |
| file\_share\_retention\_policy\_in\_days | Storage Account file shares retention policy in days. | `number` | `14` | no |
| file\_shares | List of objects to create some File Shares in this Storage Account. | <pre>list(object({<br/>    name             = string<br/>    quota_in_gb      = number<br/>    enabled_protocol = optional(string)<br/>    metadata         = optional(map(string))<br/>    acl = optional(list(object({<br/>      id          = string<br/>      permissions = string<br/>      start       = optional(string)<br/>      expiry      = optional(string)<br/>    })))<br/>  }))</pre> | n/a | yes |
| https\_traffic\_only\_enabled | Boolean flag which forces HTTPS if enabled. Disabled if any NFS file share is provisioned. | `bool` | `true` | no |
| identity\_ids | Specifies a list of User Assigned Managed Identity IDs to be assigned to this Storage Account. | `list(string)` | `null` | no |
| identity\_type | Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both). | `string` | `"SystemAssigned"` | no |
| is\_premium | True to enable `Premium` tier for this Storage Account. | `bool` | `true` | no |
| location | Azure location. | `string` | n/a | yes |
| location\_short | Short string for Azure location. | `string` | n/a | yes |
| logs\_categories | Log categories to send to destinations. | `list(string)` | `null` | no |
| logs\_destinations\_ids | List of destination resources IDs for logs diagnostic destination.<br/>Can be `Storage Account`, `Log Analytics Workspace` and `Event Hub`. No more than one of each can be set.<br/>If you want to use Azure EventHub as a destination, you must provide a formatted string containing both the EventHub Namespace authorization send ID and the EventHub name (name of the queue to use in the Namespace) separated by the <code>&#124;</code> character. | `list(string)` | n/a | yes |
| logs\_metrics\_categories | Metrics categories to send to destinations. | `list(string)` | `null` | no |
| min\_tls\_version | The minimum supported TLS version for the Storage Account. Possible values are `TLS1_0`, `TLS1_1`, and `TLS1_2`. | `string` | `"TLS1_2"` | no |
| name\_prefix | Optional prefix for the generated name. | `string` | `""` | no |
| name\_suffix | Optional suffix for the generated name. | `string` | `""` | no |
| network\_bypass | Specifies whether traffic is bypassed for 'Logging', 'Metrics', 'AzureServices' or 'None'. | `list(string)` | <pre>[<br/>  "Logging",<br/>  "Metrics",<br/>  "AzureServices"<br/>]</pre> | no |
| network\_rules\_enabled | Boolean to enable Network Rules on the Storage Account, requires `network_bypass`, `allowed_cidrs`, `subnet_ids` or `default_firewall_action` correctly set if enabled. | `bool` | `true` | no |
| private\_link\_access | List of Private Link objects to allow access from. | <pre>list(object({<br/>    endpoint_resource_id = string<br/>    endpoint_tenant_id   = optional(string, null)<br/>  }))</pre> | `[]` | no |
| resource\_group\_name | Resource group name. | `string` | n/a | yes |
| shared\_access\_key\_enabled | Indicates whether the Storage Account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). | `bool` | `false` | no |
| stack | Project stack name. | `string` | n/a | yes |
| subnet\_ids | Subnets to allow access to that Storage Account. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cifs\_credentials\_file\_content | Content of the CIFS credentials file. |
| default\_cifs\_configuration\_file\_path | Default configuration file path for CIFS credentials file. |
| file\_shares | Created file shares in the Storage Account. |
| file\_shares\_default\_fstab\_entries | Default fstab entries for the file shares. |
| file\_shares\_default\_mount\_commands | Default mount commands for the file shares. |
| file\_shares\_default\_mount\_paths | Default mount paths for the file shares. |
| file\_shares\_mount\_endpoints | Mount endpoints of created file shares. |
| file\_shares\_mount\_options | Mount options for the file shares. |
| id | Storage Account ID. |
| identity\_principal\_id | Storage Account system identity principal ID. |
| module\_diagnostics | Diagnostics settings module outputs. |
| name | Storage Account name. |
| resource | Storage Account resource object. |
<!-- END_TF_DOCS -->

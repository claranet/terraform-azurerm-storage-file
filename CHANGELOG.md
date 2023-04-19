# Unreleased

Added
  * AZ-1065: Add private_link_access option

# v7.2.0 - 2023-03-30

Added
  * AZ-1040: Enable nconnect in NFS mount options

# v7.1.2 - 2023-02-10

Fixed
  * AZ-995: Bump `storage-account` to `v7.4.x`
  * AZ-997: Fix `storage_blob_data_protection` value
  * AZ-997: Bump minimum `azurerm` version to `v3.36`

# v7.1.1 - 2023-01-13

Fixed
  * AZ-967: Fix variable `smb_properties` override
  * AZ-969: Fix issue when `backup_policy_id` is set to `null`

# v7.1.0 - 2022-11-28

Added
  * AZ-871: Add Azure File authentication block (AD/AADDS)

Changed
  * AZ-908: Use the new data source for CAF naming (instead of resource)
  * AZ-901: Change default value for variable `network_bypass` to allow `Logging, Metrics, AzureServices`

# v7.0.1 - 2022-11-04

Fixed
  * AZ-869: Fix variable description

# v7.0.0 - 2022-10-21

Added
  * AZ-869: First version

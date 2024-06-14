## 7.4.1 (2024-06-14)


### ⚠ BREAKING CHANGES

* bump minimum AzureRM provider version

### Code Refactoring

* module storage requires provider `v3.102+` 28c6aae


### Miscellaneous Chores

* **deps:** update dependency claranet/storage-account/azurerm to ~> 7.13.0 b4747d5
* **deps:** update dependency opentofu to v1.7.1 b5fb344
* **deps:** update dependency opentofu to v1.7.2 7726f04
* **deps:** update dependency pre-commit to v3.7.1 12505de
* **deps:** update dependency terraform-docs to v0.18.0 40be2d8
* **deps:** update dependency tflint to v0.51.1 84a9e55
* **deps:** update dependency trivy to v0.51.0 bba9b1d
* **deps:** update dependency trivy to v0.51.1 89f039e
* **deps:** update dependency trivy to v0.51.2 928a204
* **deps:** update dependency trivy to v0.51.4 7e07e0d
* **deps:** update dependency trivy to v0.52.0 f320b72
* **deps:** update dependency trivy to v0.52.1 376943f
* **deps:** update dependency trivy to v0.52.2 317965b

## 7.4.0 (2024-05-03)


### Features

* change `storage_blob_cors_rule` to a list, allow multiple cors rules 6e2856a


### Continuous Integration

* **AZ-1391:** enable semantic-release [skip ci] 08cb519
* **AZ-1391:** update semantic-release config [skip ci] 6b2f5af


### Miscellaneous Chores

* **deps:** add renovate.json cad935d
* **deps:** enable automerge on renovate 0436d18
* **deps:** update dependency claranet/storage-account/azurerm to ~> 7.11.0 b1d44e8
* **deps:** update dependency opentofu to v1.7.0 0ff9584
* **deps:** update dependency tflint to v0.51.0 9110b66
* **deps:** update dependency trivy to v0.50.2 92f945a
* **deps:** update dependency trivy to v0.50.4 f944c2b
* **deps:** update renovate.json acab4cf
* **deps:** update terraform claranet/storage-account/azurerm to ~> 7.10.0 ca0a2c7
* **deps:** update terraform claranet/storage-account/azurerm to ~> 7.12.0 b3c9161
* **pre-commit:** update commitlint hook 6938274
* **release:** remove legacy `VERSION` file 152aa4c

# v7.3.0 - 2023-05-05

Added
  * AZ-1065: Add `private_link_access` option

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

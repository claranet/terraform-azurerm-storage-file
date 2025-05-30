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

  location       = module.azure_region.location
  location_short = module.azure_region.location_short

  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

# module "run" {
#   source  = "claranet/run/azurerm"
#   version = "x.x.x"

#   client_name         = var.client_name
#   environment         = var.environment
#   stack               = var.stack
#   location            = module.azure_region.location
#   location_short      = module.azure_region.location_short
#   resource_group_name = module.rg.name

#   monitoring_function_enabled = false
#   vm_monitoring_enabled       = false
#   backup_vm_enabled           = false
#   update_center_enabled       = false

#   backup_file_share_enabled = true
# }

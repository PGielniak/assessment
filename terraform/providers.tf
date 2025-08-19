provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  use_cli = true
  resource_provider_registrations = "core"
  resource_providers_to_register = [
    "Microsoft.ContainerRegistry",
    "Microsoft.DBforPostgreSQL",
    "Microsoft.Network",
    "Microsoft.Web",
    "Microsoft.ManagedIdentity"
  ]
}



output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

output "webapp_url" {
  description = "URL of the web application"
  value       = module.web_app.default_site_hostname
}

output "webapp_name" {
  description = "Name of the web application"
  value       = module.web_app.name
}

output "database_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = module.database.fqdn
}

output "database_name" {
  description = "Name of the PostgreSQL server"
  value       = module.database.name
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = module.networking.vnet_id
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.networking.subnet_ids
}

output "managed_identity_id" {
  description = "ID of the managed identity"
  value       = module.identity.id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = module.identity.principal_id
}

output "postgresql_admin_password" {
  description = "PostgreSQL admin password"
  value       = var.postgresql_admin_password != null ? var.postgresql_admin_password : random_password.postgresql_admin_password[0].result
  sensitive   = true
}
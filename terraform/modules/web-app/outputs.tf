output "id" {
  description = "ID of the web app"
  value       = azurerm_linux_web_app.main.id
}

output "name" {
  description = "Name of the web app"
  value       = azurerm_linux_web_app.main.name
}

output "default_site_hostname" {
  description = "Default hostname of the web app"
  value       = azurerm_linux_web_app.main.default_hostname
}

output "outbound_ip_addresses" {
  description = "Outbound IP addresses of the web app"
  value       = azurerm_linux_web_app.main.outbound_ip_addresses
}

output "possible_outbound_ip_addresses" {
  description = "Possible outbound IP addresses of the web app"
  value       = azurerm_linux_web_app.main.possible_outbound_ip_addresses
}

output "service_plan_id" {
  description = "ID of the service plan"
  value       = azurerm_service_plan.main.id
}
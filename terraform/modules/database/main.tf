
resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "${var.name_prefix}-pg"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.postgresql_version
  delegated_subnet_id    = var.enable_private_endpoint ? null : var.db_subnet_id
  private_dns_zone_id    = var.enable_private_endpoint ? null : var.private_dns_zone_id
  administrator_login    = var.admin_login
  administrator_password = var.admin_password
  zone                   = "3"
  
  storage_mb   = var.storage_mb
  storage_tier = "P4"
  
  sku_name = var.sku_name
  
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  
  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
  }
  
  tags = var.tags
  
  lifecycle {
    ignore_changes = [
      zone,
      high_availability.0.standby_availability_zone
    ]
  }
}

# Private Endpoint for PostgreSQL (if enabled)
resource "azurerm_private_endpoint" "postgresql" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.name_prefix}-pgsql-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.db_subnet_id
  
  private_service_connection {
    name                           = "${var.name_prefix}-pgsql-private-connection"
    private_connection_resource_id = azurerm_postgresql_flexible_server.main.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
  
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
  
  tags = var.tags
}

# PostgreSQL Databases
resource "azurerm_postgresql_flexible_server_database" "databases" {
  for_each  = toset(var.databases)
  name      = each.value
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

# PostgreSQL Firewall Rules (only if not using private endpoint)
resource "azurerm_postgresql_flexible_server_firewall_rule" "allowed_ips" {
  for_each = var.enable_private_endpoint ? {} : { for idx, ip_range in var.allowed_ip_ranges : idx => ip_range }
  
  name             = "AllowedIP-${each.key}"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = split("/", each.value)[0]
  end_ip_address   = split("/", each.value)[0]
}

# PostgreSQL Configuration (key configurations from ARM template)
resource "azurerm_postgresql_flexible_server_configuration" "configs" {
  for_each = {
    shared_preload_libraries = "pg_cron,pg_stat_statements"
    log_connections         = "on"
    log_disconnections      = "on"
    log_checkpoints         = "on"
    log_min_messages        = "warning"
    require_secure_transport = "on"
  }
  
  name      = each.key
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = each.value
}

locals {
  # Generate resource group name if not provided
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : "${var.project_name}-${var.environment}"
  
  common_tags = merge({
    Environment = var.environment
  }, var.tags)
  
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "random_password" "postgresql_admin_password" {
  count   = var.postgresql_admin_password == null ? 1 : 0
  length  = 20
  special = true
}

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "networking" {
  source = "./modules/networking"
  
  name_prefix           = local.name_prefix
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  vnet_address_space    = var.vnet_address_space
  subnet_configs        = var.subnet_configs
  tags                  = local.common_tags
}

module "identity" {
  source = "./modules/identity"
  
  name                = "${local.name_prefix}-identity"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

module "database" {
  source = "./modules/database"
  
  name_prefix                = local.name_prefix
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  postgresql_version         = var.postgresql_version
  sku_name                   = var.postgresql_sku_name
  storage_mb                 = var.postgresql_storage_mb
  admin_login                = var.postgresql_admin_login
  admin_password             = var.postgresql_admin_password != null ? var.postgresql_admin_password : random_password.postgresql_admin_password[0].result
  databases                  = var.postgresql_databases
  allowed_ip_ranges          = var.allowed_ip_ranges
  enable_private_endpoint    = var.enable_private_endpoint
  virtual_network_id         = module.networking.vnet_id
  db_subnet_id               = module.networking.subnet_ids["db"]
  private_dns_zone_name      = module.networking.private_dns_zone_name
  private_dns_zone_id        = module.networking.private_dns_zone_id
  tags                       = local.common_tags
  
  depends_on = [module.networking]
}

module "web_app" {
  source = "./modules/web-app"
  
  name_prefix              = local.name_prefix
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  app_service_sku          = var.app_service_sku
  docker_image             = "${var.docker_image}"
  docker_tag               = "${var.docker_tag}"
  app_settings             = merge(var.app_settings, {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    DATABASE_URL = "postgresql+asyncpg://${var.postgresql_admin_login}:${var.postgresql_admin_password != null ? var.postgresql_admin_password : random_password.postgresql_admin_password[0].result}@${module.database.fqdn}:5432"
  })
  managed_identity_id      = module.identity.id
  managed_identity_client_id = module.identity.client_id
  webapp_subnet_id         = module.networking.subnet_ids["webapp"]
  tags                     = local.common_tags
  
  depends_on = [module.database, module.identity]
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = module.identity.principal_id
}
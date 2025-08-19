# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "${var.name_prefix}-serverfarm"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku.name
  
  tags = var.tags
}

resource "azurerm_linux_web_app" "main" {
  name                = "${var.name_prefix}-webapp"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  
  virtual_network_subnet_id = var.webapp_subnet_id
  
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }
  
  site_config {
    always_on                               = false
    container_registry_use_managed_identity = true
    container_registry_managed_identity_client_id = var.managed_identity_client_id
    
    application_stack {
      docker_image_name   = "${var.docker_image}:${var.docker_tag}"
      docker_registry_url = "https://${split("/", var.docker_image)[0]}"
    }
    
    minimum_tls_version = "1.2"
    ftps_state         = "FtpsOnly"
  }
  
  app_settings = var.app_settings
  
  tags = var.tags
}
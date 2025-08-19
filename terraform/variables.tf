variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}


variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "North Europe"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "gielniak"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Networking variables
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_configs" {
  description = "Subnet configurations"
  type = map(object({
    address_prefixes = list(string)
    delegations = list(object({
      name         = string
      service_name = string
    }))
  }))
  default = {
    default = {
      address_prefixes = ["10.0.0.0/24"]
      delegations      = []
    }
    db = {
      address_prefixes = ["10.0.1.0/24"]
      delegations      = []
    }
    webapp = {
      address_prefixes = ["10.0.2.0/24"]
      delegations = [{
        name         = "Microsoft.Web.serverFarms"
        service_name = "Microsoft.Web/serverFarms"
      }]
    }
  }
}

# Database variables
variable "postgresql_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "17"
}

variable "postgresql_sku_name" {
  description = "PostgreSQL SKU name"
  type        = string
  default     = "B_Standard_B2s"
}

variable "postgresql_storage_mb" {
  description = "PostgreSQL storage in MB"
  type        = number
  default     = 32768
}

variable "postgresql_admin_login" {
  description = "PostgreSQL admin login"
  type        = string
  default     = "postgres"
}

variable "postgresql_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
  default     = null
}

variable "postgresql_databases" {
  description = "List of databases to create"
  type        = list(string)
  default     = ["records_db"]
}

# App Service variables
variable "app_service_sku" {
  description = "App Service plan SKU"
  type = object({
    name     = string
    tier     = string
    size     = string
    capacity = number
  })
  default = {
    name     = "B1"
    tier     = "Basic"
    size     = "B1"
    capacity = 1
  }
}

variable "docker_image" {
  description = "Docker image for the web app"
  type        = string
  default     = "fastapi-test"
}

variable "docker_tag" {
  description = "Docker tag for the web app"
  type        = string
  default     = "latest"
}

variable "app_settings" {
  description = "App settings for the web app"
  type        = map(string)
  default     = {}
}

# Container Registry variables
variable "container_registry_sku" {
  description = "Container Registry SKU"
  type        = string
  default     = "Basic"
}

variable "container_registry_admin_enabled" {
  description = "Enable admin user for Container Registry"
  type        = bool
  default     = false
}

variable "container_registry_login_server" {
  description = "Container Registry login server"
  type        = string
  default     = "gielniakcontainerregistry.azurecr.io"
}

variable "container_registry_id" {
  description = "Container Registry ID"
  type        = string
  default     = "/subscriptions/c7c0f2c6-ada1-4f49-8fa4-78d422ceb45e/resourceGroups/gielniak-shared/providers/Microsoft.ContainerRegistry/registries/gielniakcontainerregistry"
}



# Security variables
variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for database access"
  type        = list(string)
  default     = []
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for PostgreSQL"
  type        = bool
  default     = true
}
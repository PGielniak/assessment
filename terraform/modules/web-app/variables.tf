variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "app_service_sku" {
  description = "App Service plan SKU"
  type = object({
    name     = string
    tier     = string
    size     = string
    capacity = number
  })
}

variable "docker_image" {
  description = "Docker image for the web app"
  type        = string
}

variable "docker_tag" {
  description = "Docker tag for the web app"
  type        = string
  default     = "latest"
}

variable "container_registry_login_server" {
  description = "Container Registry login server"
  type        = string
  default     = "gielniakcontainerregistry.azurecr.io"
}
variable "app_settings" {
  description = "App settings for the web app"
  type        = map(string)
  default     = {}
}

variable "managed_identity_id" {
  description = "ID of the managed identity"
  type        = string
}

variable "managed_identity_client_id" {
  description = "Client ID of the managed identity"
  type        = string
  default     = ""
}

variable "webapp_subnet_id" {
  description = "Subnet ID for web app VNet integration"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
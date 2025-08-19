


# Environment Configuration
environment         = "dev"
location           = "North Europe"
project_name       = "gielniak"
resource_group_name = "gielniak-development2"

# Tags
tags = {
  Environment = "dev"
}

# Networking
vnet_address_space = ["11.0.0.0/16"]
subnet_configs = {
  default = {
    address_prefixes = ["11.0.0.0/24"]
    delegations      = []
  }
  db = {
    address_prefixes = ["11.0.1.0/24"]
    delegations      = []
  }
  webapp = {
    address_prefixes = ["11.0.2.0/24"]
    delegations = [{
      name         = "Microsoft.Web.serverFarms"
      service_name = "Microsoft.Web/serverFarms"
    }]
  }
}

# Database
postgresql_version      = "16"
postgresql_sku_name    = "B_Standard_B2s"
postgresql_storage_mb  = 32768
postgresql_admin_login = "postgres"
postgresql_databases   = ["records_db"]
enable_private_endpoint = true

# App Service
app_service_sku = {
  name     = "B1"
  tier     = "Basic"
  size     = "B1"
  capacity = 1
}

docker_image = "fastapi-test"
docker_tag = "0.0.1"

app_settings = {
  "ENVIRONMENT" = "dev"
  "DEBUG"       = "true"
}

# Security
allowed_ip_ranges = [
  "195.205.202.3/32"  # My own IP
]
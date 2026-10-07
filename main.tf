# -------------------------
# Resource Group
# -------------------------

resource "azurerm_resource_group" "axion" {
  name     = var.resource_group_name
  location = var.location
}


# -------------------------
# Virtual Network
# -------------------------

resource "azurerm_virtual_network" "axion" {
  name                = var.vnet_name
  location            = azurerm_resource_group.axion.location
  resource_group_name = azurerm_resource_group.axion.name
  address_space       = ["10.10.0.0/16"]
}


# -------------------------
# AKS Subnet
# -------------------------

resource "azurerm_subnet" "aks" {
  name                 = var.aks_subnet_name
  resource_group_name  = azurerm_resource_group.axion.name
  virtual_network_name = azurerm_virtual_network.axion.name
  address_prefixes     = ["10.10.1.0/24"]
}


# -------------------------
# Azure Container Registry
# -------------------------

resource "azurerm_container_registry" "axion" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.axion.name
  location            = azurerm_resource_group.axion.location

  sku           = "Standard"
  admin_enabled = false
}


# -------------------------
# AKS Cluster
# -------------------------

resource "azurerm_kubernetes_cluster" "axion" {
  name                = var.aks_name
  location            = azurerm_resource_group.axion.location
  resource_group_name = azurerm_resource_group.axion.name
  dns_prefix          = "axionaks"

  default_node_pool {
    name           = "system"
    vm_size        = "Standard_DS2_v2"
    node_count     = 2
    vnet_subnet_id = azurerm_subnet.aks.id
  }
  node_provisioning_profile {
    mode = "Auto"
  }
  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    pod_cidr            = "10.244.0.0/16"
    service_cidr        = "10.0.0.0/16"
    dns_service_ip      = "10.0.0.10"
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  depends_on = [
    azurerm_subnet.aks
  ]
}


# -------------------------
# AKS -> ACR Pull Permission
# -------------------------

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.axion.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.axion.kubelet_identity[0].object_id

  depends_on = [
    azurerm_kubernetes_cluster.axion,
    azurerm_container_registry.axion
  ]
}

# -------------------------
# PostgreSQL Flexible Server
# -------------------------

resource "azurerm_postgresql_flexible_server" "axion" {
  name                = var.postgres_server_name
  resource_group_name = azurerm_resource_group.axion.name
  location            = azurerm_resource_group.axion.location
  version             = "18"

  administrator_login    = var.postgres_admin_username
  administrator_password = var.postgres_admin_password

  storage_mb = 32768

  sku_name = "B_Standard_B1ms"

  backup_retention_days = 7

  public_network_access_enabled = true
}


# -------------------------
# PostgreSQL Database
# -------------------------

resource "azurerm_postgresql_flexible_server_database" "axion" {
  name      = var.postgres_database_name
  server_id = azurerm_postgresql_flexible_server.axion.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}


# -------------------------
# Allow Azure Services
# -------------------------

resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.axion.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
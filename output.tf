output "resource_group_name" {
  value = azurerm_resource_group.axion.name
}

output "vnet_name" {
  value = azurerm_virtual_network.axion.name
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks.id
}

output "acr_login_server" {
  value = azurerm_container_registry.axion.login_server
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.axion.name
}

output "aks_fqdn" {
  value = azurerm_kubernetes_cluster.axion.fqdn
}
output "postgres_server_fqdn" {
  value = azurerm_postgresql_flexible_server.axion.fqdn
}

output "postgres_database_name" {
  value = azurerm_postgresql_flexible_server_database.axion.name
}

output "postgres_admin_username" {
  value = var.postgres_admin_username
}
variable "location" {
  description = "Azure region"
  type        = string
  default     = "South India"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "axion-rg"
}

variable "vnet_name" {
  description = "VNet name"
  type        = string
  default     = "axion-vnet"
}

variable "aks_subnet_name" {
  description = "AKS subnet name"
  type        = string
  default     = "aks-subnet"
}

variable "acr_name" {
  description = "Globally unique ACR name"
  type        = string
  default     = "axionacr12345"
}

variable "aks_name" {
  description = "AKS cluster name"
  type        = string
  default     = "axion-aks"
}
variable "postgres_server_name" {
  description = "Globally unique PostgreSQL Flexible Server name"
  type        = string
  default     = "axion-postgres-12345"
}

variable "postgres_admin_username" {
  description = "PostgreSQL administrator username"
  type        = string
  default     = "pgadmin"
}

variable "postgres_admin_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true
}

variable "postgres_database_name" {
  description = "Application database name"
  type        = string
  default     = "axiondb"
}
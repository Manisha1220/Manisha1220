data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                = var.kv_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days = 90
  purge_protection_enabled   = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover", "Backup", "Restore"
    ]
  }
}

# Random password
resource "random_password" "pg_admin" {
  length           = 20
  special          = true
  override_special = "!@#%^&*()-_=+[]{}"
}

# Store secret
resource "azurerm_key_vault_secret" "pg_admin" {
  name         = var.pg_admin_secret_name
  value        = random_password.pg_admin.result
  key_vault_id = azurerm_key_vault.kv.id

  content_type = "postgres-admin-password"
}
# Read secret
data "azurerm_key_vault_secret" "pg_admin" {
  name         = azurerm_key_vault_secret.pg_admin.name
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_key_vault_secret.pg_admin]
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "pg" {
  name                = var.pg_server_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  version = "16"

  administrator_login    = var.pg_admin_user
  administrator_password = data.azurerm_key_vault_secret.pg_admin.value

  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768
  zone       = "1"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  public_network_access_enabled = true
}

# Firewall rule
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_me" {
  name             = "allow-my-ip"
  server_id        = azurerm_postgresql_flexible_server.pg.id
  start_ip_address = var.allow_ip
  end_ip_address   = var.allow_ip
}

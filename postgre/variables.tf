variable "location" {
  description = "Azure region"
  type        = string
  default     = "Central India"
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-kv-pgflex-demo"
}

variable "kv_name" {
  description = "Key Vault name (must be globally unique)"
  type        = string
  default     = "kv-pgflex-demo-1234"
}

variable "pg_server_name" {
  description = "PostgreSQL Flexible Server name"
  type        = string
  default     = "pgflex-demo-1234"
}

variable "pg_admin_user" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "pgadminuser"
}

variable "pg_admin_secret_name" {
  description = "Key Vault secret name"
  type        = string
  default     = "pg-admin-password"
}

variable "allow_ip" {
  description = "Your public IP"
  type        = string
  default     = "203.0.113.45"
}
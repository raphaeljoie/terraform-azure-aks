variable "region" {
  type        = string
  default     = "West Europe"
  description = "Default deployment region"
}

variable "resource_group" {
  type        = string
  description = "Resource group to gather the items"
}


variable "resource_group_exists" {
  type        = bool
  default     = false
  description = "Whether the resource group must be created or loaded"
}

variable "resource_group_managed" {
  type        = string
  default     = null
  description = "Resource group for Azure to store managed resources. Must be non existing. Default is {var.resource_group}-managed-resources"
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster, also used to create variants for naming other resources"
}

variable "log_analytics_workspace" {
  type        = string
  default     = null
  description = "Name of the log analytics workspace. aks-{cluster_name} used if not provided"
}

variable "log_analytics_retention_in_days" {
  type        = number
  default     = 30
  description = "Retention for the log analytics workspace"
}

variable "log_analytics_workspace_sku" {
  type        = string
  default     = "PerGB2018"
  description = "Sku for logs"
}

variable "cluster_identity" {
  type        = string
  default     = "SystemAssigned"
  description = "Whether the cluster identity should be Azure managed or custom identity"
  validation {
    condition = var.cluster_identity == "SystemAssigned" || var.cluster_identity == "UserAssigned"
    error_message = "Cluster identity must be 'SystemAssigned' or 'UserAssigned'"
  }
}

variable "cluster_identity_name" {
  type        = string
  default     = null
  description = ""
}

variable "cluster_identity_id" {
  type        = string
  default     = null
  description = ""
}

variable "load_balancer_sku" {
  type = string
  default = "Basic"
  description = "Sku for load Balancers. Also apply to Public IP Address"
  validation {
    condition = var.load_balancer_sku == "Standard" || var.load_balancer_sku == "Basic"
    error_message = "load_balancer_sku must be Standard or Basic"
  }
}

variable "public_ip_address" {
  type        = string
  default     = null
  description = "Free Public IP Address to use with load Balancer. Must match the SKU of Load Balancer (var.load_balancer_sku). A public IP Address is created if none provided"
}

variable "public_ip_name" {
  type        = string
  default     = null
  description = "Name of the public IP Address to be created when no public_ip_address is provided"
}

variable "http_application_routing_enabled" {
  type        = bool
  default     = false
  description = "Enable the [managed DNS and ingress](https://learn.microsoft.com/en-us/azure/aks/http-application-routing)"
}

variable "sku_tier" {
  type        = string
  default     = "Free"
  description = ""
  validation {
    condition = var.sku_tier == "Free" || var.sku_tier == "Paid"
    error_message = "Sku Tier must be Free or Paid"
  }
}

variable "admin_user_group_id" {
  type        = string
  default     = null
  description = ""
}

variable "admin_user_group_tenant_id" {
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = ""
}

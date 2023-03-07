
output "client_id" {
  value = data.azuread_client_config.current.client_id
}

output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "public_ip_address" {
  value = local.public_ip_address
}

output "load_balancer_ip" {
  value = local.public_ip_address
}

output "kube_config_raw" {
  value = azurerm_kubernetes_cluster.this.kube_config_raw

  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.this.kube_config

  sensitive = true
}

output "kube_config_exec" {
  value =  local.kube_config_exec
}

output "kube_login" {
  value = [
    "az login",
    "az account set --subscription ${data.azurerm_subscription.current.id}",
    "az aks get-credentials --resource-group ${local.resource_group_name} --name ${azurerm_kubernetes_cluster.this.name}"
  ]

  description = "AZ commands to execute to connect to the cluster and be ready to kubectl something"
}


# Static outputs

output "resource_group" {
  value = var.resource_group
}

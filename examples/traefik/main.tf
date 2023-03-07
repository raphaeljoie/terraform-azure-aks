provider "azurerm" {
  features {}
}

module "cluster" {
  source = "../../modules/cluster"

  cluster_name = "widespot"
  resource_group = "rg-aks-traefik"
  cluster_identity = "SystemAssigned"
}

output "kube_config_exec" {
  value =  module.cluster.kube_config_exec
}

output "client_id" {
  value = module.cluster.client_id
}

output "tenant_id" {
  value = module.cluster.tenant_id
}

resource "helm_release" "application" {
  count = 0

  name       = "my-local-chart"
  chart      = "./example/chart"

  depends_on = [module.cluster]
}

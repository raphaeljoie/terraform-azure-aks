provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "cluster" {
  source = "../../modules/cluster"

  cluster_name = "widespot"
  resource_group = "rg-widespot"
  cluster_identity = "SystemAssigned"
  http_application_routing_enabled = true
}

module "application-routing-output" {
  source = "../../modules/application_routing_output"

  resource_group = module.cluster.resource_group
  cluster_name = module.cluster.cluster_name

  depends_on = [module.cluster]
}

resource "helm_release" "application" {
  name       = "my-local-chart"
  chart      = "./example/chart"

  set {
    name = "host"
    value = "aks-helloworld.${module.application-routing-output.zone_name}"
  }
}

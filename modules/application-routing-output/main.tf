locals {
  command = "/bin/bash az aks show --resource-group ${var.resource_group} --name ${var.cluster_name} --query addonProfiles.httpApplicationRouting.config -o json"
}

locals {
  command_list = split(" ", local.command)
}

data "external" "cluster_application_routing_zone_name" {
  program = local.command_list
}

# data "azurerm_lb" "" {
#  name = "kubernetes"
#  resource_group_name = var.resource_group
# }

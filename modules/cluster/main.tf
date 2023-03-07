#### Resource Group ####

resource "azurerm_resource_group" "resource_group" {
  count     = !var.resource_group_exists ? 1 : 0
  name      = var.resource_group
  location  = var.region
}

locals {
  resource_group_id = !var.resource_group_exists ? azurerm_resource_group.resource_group[0].id : data.azurerm_resource_group.this[0].id
  resource_group_name = !var.resource_group_exists ? azurerm_resource_group.resource_group[0].name : data.azurerm_resource_group.this[0].name
  resource_group_location = !var.resource_group_exists ? azurerm_resource_group.resource_group[0].location : data.azurerm_resource_group.this[0].location
}

#### Logs ####

resource "azurerm_log_analytics_workspace" "log_workspace" {
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name

  name                = coalesce(var.log_analytics_workspace, "aks-${var.cluster_name}")

  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_retention_in_days
}

#### Admin User Group ####

resource "azuread_group" "admin_user_group" {
  count = var.admin_user_group_id == null ? 1 : 0

  display_name     = "aks-${var.cluster_name}-admins"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}

resource "azuread_group_member" "example" {
  count = var.admin_user_group_id == null ? 1 : 0

  group_object_id  = azuread_group.admin_user_group[0].id
  member_object_id = data.azuread_client_config.current.object_id
}

#### Networking ####
# a lot TODO here

resource "azurerm_virtual_network" "vnet" {
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name

  name                = "aks-${var.cluster_name}-vnet"

  address_space       = ["10.224.0.0/12"]
}

resource "azurerm_subnet" "default_subnet" {
  resource_group_name   = local.resource_group_name

  name                  = "default"

  virtual_network_name  = azurerm_virtual_network.vnet.name
  address_prefixes      = ["10.224.0.0/16"]

  private_endpoint_network_policies_enabled = true
}

resource "azurerm_subnet" "virtual_nodes_subnet" {
  resource_group_name   = local.resource_group_name

  name                  = "virtual-node-aci"

  virtual_network_name  = azurerm_virtual_network.vnet.name
  address_prefixes      = ["10.239.0.0/16"]

  private_endpoint_network_policies_enabled = true

  delegation {
    name = "aciDelegation"
    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
      name    = "Microsoft.ContainerInstance/containerGroups"
    }
  }
}


#### Public IP Address ####

resource "azurerm_public_ip" "ip" {
  count = var.public_ip_address == null ? 1 : 0

  location = local.resource_group_location
  resource_group_name = local.resource_group_name

  sku = var.load_balancer_sku

  name = coalesce(var.public_ip_name, "aks-${var.cluster_name}")

  allocation_method = "Static"
}

locals {
  public_ip_address = var.public_ip_address != null ? var.public_ip_address : azurerm_public_ip.ip[0].ip_address
}

resource "azurerm_user_assigned_identity" "this" {
  count = var.cluster_identity == "UserAssigned" && var.cluster_identity_id == null ? 1 : 0

  location = local.resource_group_location
  resource_group_name = local.resource_group_name

  name = coalesce(var.cluster_identity_name, "aks-${var.cluster_name}")
}

resource "azurerm_kubernetes_cluster" "this" {
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name

  name                = var.cluster_name

  # ?
  dns_prefix          = "aks-${var.cluster_name}"

  node_resource_group = coalesce(var.resource_group_managed, "${local.resource_group_name}-managed-resources")

  # The HTTP application routing add-on is designed to let you quickly create an ingress controller and
  # access your applications. This add-on is not currently designed for use in a production environment
  # and is not recommended for production use. For production-ready ingress deployments that include
  # multiple replicas and TLS support, see Create an HTTPS ingress controller.
  # https://learn.microsoft.com/en-us/azure/aks/http-application-routing
  http_application_routing_enabled = var.http_application_routing_enabled

  # ?
  automatic_channel_upgrade = "patch"
  # ?
  private_cluster_enabled = false
  # ?
  local_account_disabled = true
  # ?
  open_service_mesh_enabled = false

  aci_connector_linux {
    subnet_name = azurerm_subnet.virtual_nodes_subnet.name
  }

  azure_active_directory_role_based_access_control {
    admin_group_object_ids = [
      var.admin_user_group_id != null ? var.admin_user_group_id : azuread_group.admin_user_group[0].id
    ]
    azure_rbac_enabled     = false
    managed                = true
    tenant_id              = var.admin_user_group_tenant_id
  }

  default_node_pool {
    enable_auto_scaling = true
    name                = "system"
    node_count          = 1
    max_count           = 5
    min_count           = 1
    vm_size             = "Standard_B4ms"
    vnet_subnet_id      = azurerm_subnet.default_subnet.id
    #zones = ["1", "2", "3"]
  }


  # AKS uses several managed identities for built-in services and add-ons.
  # https://learn.microsoft.com/en-us/azure/aks/use-managed-identity
  identity {
    type = var.cluster_identity  # SystemAssigned or UserAssigned
    identity_ids = var.cluster_identity == "SystemAssigned" ? null : [var.cluster_identity_id != null ? var.cluster_identity_id : azurerm_user_assigned_identity.this[0].id]
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id
  }

  tags = var.tags

  sku_tier = var.sku_tier

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    # Believe it or not, IP Sku are Camel case, Load balancer sku ar lower case
    load_balancer_sku = lower(var.load_balancer_sku)
  }
}

# see https://learn.microsoft.com/en-us/azure/aks/static-ip
# TODO only create if needed
# TODO review actual policy
resource "azurerm_role_definition" "cluster_role" {
  name = "Aks${var.cluster_name}"
  scope = local.resource_group_id

  permissions {
    actions = [
      "Microsoft.Network/publicIPAddresses/read"
    ]
  }
}

resource "azurerm_role_assignment" "cluster_network_contributor_role" {
  principal_id = var.cluster_identity_id == null && var.cluster_identity_name == null ? azurerm_kubernetes_cluster.this.identity[0].principal_id : list(azurerm_kubernetes_cluster.this.identity[0].identity_ids)[0]
  #role_definition_id = data.azurerm_role_definition.cluster_role.id
  role_definition_name = "Network Contributor"
  scope = local.resource_group_id
}

locals {
  kube_config_exec = {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = [
      "get-token",
      "--environment",
      "AzurePublicCloud",
      # Note: The AAD server app ID of AKS Managed AAD is always 6dae42f8-4368-4678-94ff-3960e28e3630 in any environments.
      "--server-id",
      "6dae42f8-4368-4678-94ff-3960e28e3630",
      # Why not data.azuread_client_config.current.client_id ???
      "--client-id",
      "80faf920-1908-4b52-b5ef-a8e7bedfc67a",
      "--tenant-id",
      data.azuread_client_config.current.tenant_id,
      "--login",
      "devicecode"
    ]
    command     = "kubelogin"
  }
}

#### Ingress with Traefik ####

provider "helm" {
  alias = "traefik-ingress"

  kubernetes {
    host                   = azurerm_kubernetes_cluster.this.kube_config.0.host
    #username               = azurerm_kubernetes_cluster.this.kube_config.0.username
    #password               = azurerm_kubernetes_cluster.this.kube_config.0.password
    client_certificate     = base64decode(azurerm_kubernetes_cluster.this.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.this.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.this.kube_config.0.cluster_ca_certificate)

    exec {
      api_version = local.kube_config_exec.api_version
      args        = local.kube_config_exec.args
      command     = local.kube_config_exec.command
    }
  }
}

resource "helm_release" "ingress" {
  count = 0
  provider = helm.traefik-ingress

  name       = "traefik-ingress"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  namespace  = "traefik"

  timeout    = 100

  values = [
    "${file("${path.module}/values.yml")}"
  ]

  # Deprecated
  # https://github.com/Azure/AKS/issues/3122
  # https://github.com/kubernetes-sigs/cloud-provider-azure/pull/3019
  set {
    name  = "service.spec.loadBalancerIP"
    value = local.public_ip_address
  }

  # https://cloud-provider-azure.sigs.k8s.io/topics/loadbalancer/
  set {
    name = "service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-ipv4"
    value = local.public_ip_address
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    value = local.resource_group_name
  }
}

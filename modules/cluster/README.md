# Deploy a AKS 
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.15.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.20.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=2.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 2.15.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.20.0 |
| <a name="provider_helm.traefik-ingress"></a> [helm.traefik-ingress](#provider\_helm.traefik-ingress) | >=2.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_group.admin_user_group](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_group_member.example](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azurerm_kubernetes_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_log_analytics_workspace.log_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_public_ip.ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.cluster_network_contributor_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.cluster_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_subnet.default_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.virtual_nodes_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [helm_release.ingress](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_user_group_id"></a> [admin\_user\_group\_id](#input\_admin\_user\_group\_id) | n/a | `string` | `null` | no |
| <a name="input_admin_user_group_tenant_id"></a> [admin\_user\_group\_tenant\_id](#input\_admin\_user\_group\_tenant\_id) | n/a | `string` | `null` | no |
| <a name="input_cluster_identity"></a> [cluster\_identity](#input\_cluster\_identity) | Whether the cluster identity should be Azure managed or custom identity | `string` | `"SystemAssigned"` | no |
| <a name="input_cluster_identity_id"></a> [cluster\_identity\_id](#input\_cluster\_identity\_id) | n/a | `string` | `null` | no |
| <a name="input_cluster_identity_name"></a> [cluster\_identity\_name](#input\_cluster\_identity\_name) | n/a | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster, also used to create variants for naming other resources | `string` | n/a | yes |
| <a name="input_http_application_routing_enabled"></a> [http\_application\_routing\_enabled](#input\_http\_application\_routing\_enabled) | Enable the [managed DNS and ingress](https://learn.microsoft.com/en-us/azure/aks/http-application-routing) | `bool` | `false` | no |
| <a name="input_load_balancer_sku"></a> [load\_balancer\_sku](#input\_load\_balancer\_sku) | Sku for load Balancers. Also apply to Public IP Address | `string` | `"Basic"` | no |
| <a name="input_log_analytics_retention_in_days"></a> [log\_analytics\_retention\_in\_days](#input\_log\_analytics\_retention\_in\_days) | Retention for the log analytics workspace | `number` | `30` | no |
| <a name="input_log_analytics_workspace"></a> [log\_analytics\_workspace](#input\_log\_analytics\_workspace) | Name of the log analytics workspace. aks-{cluster\_name} used if not provided | `string` | `null` | no |
| <a name="input_log_analytics_workspace_sku"></a> [log\_analytics\_workspace\_sku](#input\_log\_analytics\_workspace\_sku) | Sku for logs | `string` | `"PerGB2018"` | no |
| <a name="input_public_ip_address"></a> [public\_ip\_address](#input\_public\_ip\_address) | Free Public IP Address to use with load Balancer. Must match the SKU of Load Balancer (var.load\_balancer\_sku). A public IP Address is created if none provided | `string` | `null` | no |
| <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name) | Name of the public IP Address to be created when no public\_ip\_address is provided | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Default deployment region | `string` | `"West Europe"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Resource group to gather the items | `string` | n/a | yes |
| <a name="input_resource_group_exists"></a> [resource\_group\_exists](#input\_resource\_group\_exists) | Whether the resource group must be created or loaded | `bool` | `false` | no |
| <a name="input_resource_group_managed"></a> [resource\_group\_managed](#input\_resource\_group\_managed) | Resource group for Azure to store managed resources. Must be non existing. Default is {var.resource\_group}-managed-resources | `string` | `null` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | n/a | `string` | `"Free"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | n/a |
| <a name="output_kube_config_exec"></a> [kube\_config\_exec](#output\_kube\_config\_exec) | n/a |
| <a name="output_kube_config_raw"></a> [kube\_config\_raw](#output\_kube\_config\_raw) | n/a |
| <a name="output_kube_login"></a> [kube\_login](#output\_kube\_login) | AZ commands to execute to connect to the cluster and be ready to kubectl something |
| <a name="output_load_balancer_ip"></a> [load\_balancer\_ip](#output\_load\_balancer\_ip) | n/a |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | n/a |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | n/a |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | n/a |
<!-- END_TF_DOCS -->

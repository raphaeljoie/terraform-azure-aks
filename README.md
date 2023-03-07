# Kubernetes with Azure AKS

Easy deployment of a public Kubernetes cluster thanks to AKS
* [x] Ingress Controller using Traefik and/or Azure provided HTTP Application Routing
* [x] Active Directory authentication, in sync with Kubernetes RBAC

## Usage
```shell
$ terraform apply
```

> **WARNING** when the admin user group must be created, it can take an hour or two
> before the current user membership is propagated. 

```tf
module "cluster" {
  source = "git::https://github.com/raphaeljoie/terraform-azure-aks.git//modules/cluster"

  resource_group = "rg-widespot"
  cluster_name = "widespot"
}

module "cluster_output" {
  source = "git::https://github.com/raphaeljoie/terraform-azure-aks.git//modules/application_routing_output"

  resource_group = module.cluster.resource_group
  cluster_name = module.cluster.cluster_name

  depends_on = [module.cluster]
}
```

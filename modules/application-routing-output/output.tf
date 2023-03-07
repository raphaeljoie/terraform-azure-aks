output "zone_name" {
  value = data.external.cluster_application_routing_zone_name.result.HTTPApplicationRoutingZoneName
}

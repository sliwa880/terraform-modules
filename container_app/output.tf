output "container_principal_id" {
  value = azapi_resource.container_app.identity[0].principal_id
}

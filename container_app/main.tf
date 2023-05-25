locals {
  base_name = "${var.product_name}-${var.service_name}-${var.environment}-${local.location_name}"
  location_map = {
    westeurope = "westeu"
    ukwest     = "ukwest"
    uksouth    = "uksouth"
  }

  location_name = lookup(local.location_map, var.location, "NA")
}

data "azurerm_container_registry" "sat_acr" {
  name                = var.container_registry_name
  resource_group_name = var.core_resource_group_name
}

resource "azurerm_user_assigned_identity" "container_app" {
  name                = "${local.base_name}-mi"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "role_assignment_container_app" {
  scope                = data.azurerm_container_registry.sat_acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.container_app.principal_id
}

resource "azapi_resource" "container_app" {
  name      = "${local.base_name}-ca"
  type      = "Microsoft.App/containerApps@2022-03-01"
  parent_id = var.resource_group_id
  location  = var.location
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_app.id]
  }

  body = jsonencode({
    properties : {
      managedEnvironmentId = var.container_app_environment_id
      configuration = {
        ingress = {
          external   = true
          targetPort = 80
        }
        # dapr = {
        #   appId = var.service_name
        #   appPort = var.dapr_app_port
        #   appProtocol = "http"
        #   enabled = var.is_dapr_enabled
        # }
        registries = [
          {
            server   = data.azurerm_container_registry.sat_acr.login_server
            identity = azurerm_user_assigned_identity.container_app.id
          }
        ]
        secrets = var.container_app_secrets
      }
      template = {
        containers = [
          {
            name  = var.service_name
            image = "${data.azurerm_container_registry.sat_acr.login_server}/${var.image_repository}:${var.image_tag}"
            resources = {
              cpu    = var.resources.cpu
              memory = var.resources.memory
            }
            env = var.container_app_env_variables
        }]
        scale = {
          minReplicas = var.scale.minReplicas
          maxReplicas = var.scale.maxReplicas
        }
      }
    }
  })
  tags = var.tags

  depends_on = [
    azurerm_role_assignment.role_assignment_container_app
  ]
}

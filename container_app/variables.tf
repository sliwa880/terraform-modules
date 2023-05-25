variable "product_name" {
  description = "The Azure resource prefix"
}

variable "service_name" {
  description = "The image name the service"
}

variable "location" {
  description = "The Azure location where Container App should be created (uksouth / ukwest / westeurope )"
}

variable "environment" {
  description = "The target environment is used to compose the dependent resource name ( ci / test / prod )"
}

variable "resource_group_name" {
  description = "The name of resource group where Managed Identity resource should be created"
}

variable "resource_group_id" {
  description = "The id of resource group where Container App should be created"
}

variable "container_app_environment_id" {
  description = "The id of Container App Environment where Container App will be attached"
}

variable "container_registry_name" {
  default     = "sattestuksouthacr"
  description = "Name of azure container registry"
}

variable "core_resource_group_name" {
  default     = "sat-core-test-uksouth-rg"
}

variable "image_repository" {
  description = "The image name used in Container App"
}

variable "image_tag" {
  default     = "latest"
  description = "The image tag used in Container App"
}

variable "dapr_app_port" {
  description = "Tells Dapr which port your application is listening on"
  default     = 80
}

variable "is_dapr_enabled" {
  description = "Boolean indicating if the Dapr side car is enabled"
  default     = true
}

variable "resources" {
  type = object({
    cpu    = number # 0.25
    memory = string # "0.5Gi"
  })
}

variable "scale" {
  type = object({
    minReplicas = number # 1
    maxReplicas = number # 1
  })
}

variable "container_app_env_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "container_app_secrets" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "tags" {
  type = any
}

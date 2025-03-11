terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.22.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "ac750edc-c180-47c1-b84b-189beb733972"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-traffic"
  location = "brazilsouth"
}

resource "azurerm_traffic_manager_profile" "traffic" {
  name                   = "trafficluiz"
  resource_group_name    = azurerm_resource_group.rg.name
  traffic_routing_method = "Geographic"

  dns_config {
    relative_name = "trafficluiz"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

// APP SERVICE AND SERVICE PLAN FOR BRAZIL
resource "azurerm_app_service_plan" "planbr" {
  name                = "planbr"
  location            = "brazilsouth"
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "appservicebr" {
  name                = "appservicebrluiz"
  location            = azurerm_app_service_plan.planbr.location
  app_service_plan_id = azurerm_app_service_plan.planbr.id
  resource_group_name = azurerm_resource_group.rg.name
}

// APP SERVICE AND SERVICE PLAN FOR USA
resource "azurerm_app_service_plan" "planeua" {
  name                = "planeua"
  location            = "West US"
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "appserviceusa" {
  name                = "appserviceusaluiz"
  location            = azurerm_app_service_plan.planeua.location
  app_service_plan_id = azurerm_app_service_plan.planeua.id
  resource_group_name = azurerm_resource_group.rg.name
}

// APP SERVICE AND SERVICE PLAN FOR WORLD
resource "azurerm_app_service_plan" "planWorld" {
  name                = "planWorld"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "appserviceworld" {
  name                = "appserviceworldluiz"
  location            = azurerm_app_service_plan.planWorld.location
  app_service_plan_id = azurerm_app_service_plan.planWorld.id
  resource_group_name = azurerm_resource_group.rg.name
}

// TRAFFIC MANAGER ENDPOINTS

resource "azurerm_traffic_manager_azure_endpoint" "cdnendpoinTbr" {
  name                       = "trafficbrluiz"
  profile_id                 = azurerm_traffic_manager_profile.traffic.id
  target_resource_id         = azurerm_app_service.appservicebr.id
  weight                     = 100

  geo_mappings = ["BR"]
}

resource "azurerm_traffic_manager_azure_endpoint" "cdnendpointeua" {
  name                       = "trafficeualuiz"
  profile_id                 = azurerm_traffic_manager_profile.traffic.id
  target_resource_id         = azurerm_app_service.appserviceusa.id
  weight                     = 101

  geo_mappings = ["US"]
}

resource "azurerm_traffic_manager_azure_endpoint" "cdnendpointworld" {
  name                       = "trafficworldluiz"
  profile_id                 = azurerm_traffic_manager_profile.traffic.id
  target_resource_id         = azurerm_app_service.appserviceworld.id
  weight                     = 102

  geo_mappings = ["WORLD"]
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "meta"
    storage_account_name = "hackathonterraform"
    container_name       = "tfstate"
    key                  = "light.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

locals {
  name = "light"
}


resource "azurerm_resource_group" "global" {
  name     = local.name
  location = "West Europe"
}

# AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.name
  resource_group_name = azurerm_resource_group.global.name
  location            = azurerm_resource_group.global.location
  dns_prefix          = local.name
  node_resource_group = format("%s-%s", azurerm_resource_group.global.name, "aksrg")

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2s_v3"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Referenz zu einer extern erstellten Container Registry
data "azurerm_container_registry" "acr" {
  name                = "2021hackathon"
  resource_group_name = "meta"
}

# Registry Pull Berechtigung für das Cluster
resource "azurerm_role_assignment" "acr" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

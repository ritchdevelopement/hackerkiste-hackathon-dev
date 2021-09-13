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

variable "name" {
  type        = string
  description = "Name den die Resourcen in Azure haben sollen. Muss alphanumerisch sein."
  default     = "light"
}

resource "azurerm_resource_group" "global" {
  name     = var.name
  location = "West Europe"
}

# AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  resource_group_name = azurerm_resource_group.global.name
  location            = azurerm_resource_group.global.location
  dns_prefix          = var.name
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

output "info" {
  value = format(<<EOT
    Um auf das Cluster zuzugreifen öffne die Azure Shell und führe die folgenden Befehle aus:
    
    az aks get-credentials --resource-group %s --name %s
    kubectl get nodes
    EOT
    , azurerm_kubernetes_cluster.aks.resource_group_name,
    azurerm_kubernetes_cluster.aks.name)
}
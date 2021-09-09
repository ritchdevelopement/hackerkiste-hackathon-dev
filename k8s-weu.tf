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
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

module "instance-weu" {
  source = "./modules/kubernetesinstance"

  prefix   = "tim"
  location = "West Europe"
  networks = {
    external = "10.0.0.0/24"
    internal = "172.16.0.0/16"
  }
  kubernetes_version = "1.21.2"
}

module "instance-weu-np-1" {
  source = "./modules/kubernetesnodepool"

  name = "np1"
  #max_count = 1
  #vm_size = "Standard_D1_v2"
  kubernetes_cluster = module.instance-weu.kubernetes_cluster
}

output "info" {
  value = format("Um auf das Cluster zuzugreifen öffne die Azure Shell und führe die folgenden Befehle aus:\n\naz aks get-credentials --resource-group %s --name %s\nkubectl get nodes\n", module.instance-weu.kubernetes_cluster.resource_group_name, module.instance-weu.kubernetes_cluster.name)
}
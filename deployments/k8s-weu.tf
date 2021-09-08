provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

module "instance-weu" {
    source = "../modules/iaas/kubernetesinstance"
    
    prefix   = "tim"
    location = "West Europe"
    #kubernetes_service_subnets = ["172.16.0.0/16"]
    networks = {
        external = "10.0.0.0/24"
        internal = "172.16.0.0/16"
    }
    kubernetes_version = "1.21.2"

    registry_id = "" #TODO
}

module "instance-1-np-1" {
    source = "../modules/iaas/kubernetesnodepool"

    name = "tk8si1np1" #max 8 chars
    #max_count = 1
    #vm_size = "Standard_D1_v2"
    kubernetes_cluster = module.instance-weu.kubernetes_cluster
    #labels = {}
    #taints = []
}

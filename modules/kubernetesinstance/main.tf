# Resource Group
resource "azurerm_resource_group" "global" {
  name     = var.prefix
  location = var.location
}

# AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                    = var.prefix
  resource_group_name     = azurerm_resource_group.global.name
  location                = var.location
  dns_prefix              = format("%s-%s", var.prefix, "hackathon")
  node_resource_group     = format("%s-%s", azurerm_resource_group.global.name, "aksrg")
  private_cluster_enabled = false

  default_node_pool {
    name                  = "default"
    enable_auto_scaling   = true
    min_count             = 1
    max_count             = 10
    vm_size               = "Standard_D2s_v3"
    vnet_subnet_id        = azurerm_subnet.external.id
    availability_zones    = [1, 2, 3]
    enable_node_public_ip = false
    type                  = "VirtualMachineScaleSets"

    orchestrator_version = var.kubernetes_version
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    service_cidr       = "192.168.0.0/17"
    dns_service_ip     = "192.168.0.10"
    docker_bridge_cidr = "192.168.128.1/17"
    outbound_type      = "loadBalancer"
    load_balancer_sku  = "standard"
  }

  kubernetes_version = var.kubernetes_version
  sku_tier           = "Free"

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    kube_dashboard {
      enabled = false
    }
    oms_agent {
      enabled = false
    }
    azure_policy {
      enabled = true
    }
    aci_connector_linux {
      enabled = false
    }
    http_application_routing {
      enabled = false #insecure, missing tls
    }
  }

  auto_scaler_profile {
    balance_similar_node_groups      = false
    max_graceful_termination_sec     = 600
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s" #defaults to scan interval
    scale_down_delay_after_failure   = "3m"
    scan_interval                    = "10s"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = 0.5
  }
}

#Registry Pull Permission for the Cluster
resource "azurerm_role_assignment" "acr" {
  count = var.registry_id == "" ? 0 : 1 #TEMP. TODO REMOVE

  scope                = var.registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

##grant Managed Idenitity (network change permission for APPGW?)
#resource "azurerm_role_assignment" "network" {
#  for_each = azurerm_kubernetes_cluster.aks
#
#  scope              = azurerm_virtual_network.net.id
#  role_definition_name = "Contributor"
#  principal_id       = azurerm_kubernetes_cluster.aks.identity.0.principal_id
#}

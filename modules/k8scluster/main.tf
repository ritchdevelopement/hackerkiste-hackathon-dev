# Resource Group
resource "azurerm_resource_group" "global" {
  name     = var.prefix
  location = var.location
}

# Network Setup
resource "azurerm_virtual_network" "net" {
  name                = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.global.name
  address_space       = [var.node_network]
  dns_servers         = ["1.1.1.1", "1.0.0.1", "8.8.8.8"]
}

resource "azurerm_subnet" "nodes" {
  name                 = format("%s%s", var.prefix, "nodes")
  resource_group_name  = azurerm_virtual_network.net.resource_group_name
  virtual_network_name = azurerm_virtual_network.net.name
  address_prefixes     = [var.node_network]
}

resource "azurerm_route_table" "nodes" {
  name                          = format("%s%s", var.prefix, "nodes")
  location                      = var.location
  resource_group_name           = azurerm_virtual_network.net.resource_group_name
  disable_bgp_route_propagation = false
}

resource "azurerm_subnet_route_table_association" "nodes" {
  subnet_id      = azurerm_subnet.nodes.id
  route_table_id = azurerm_route_table.nodes.id

  depends_on = [
    azurerm_route_table.nodes,
    azurerm_subnet.nodes,
  ]
}

resource "azurerm_network_security_group" "nodes" {
  name                = format("%s%s", var.prefix, "nodes")
  location            = azurerm_resource_group.global.location
  resource_group_name = azurerm_resource_group.global.name
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
    vnet_subnet_id        = azurerm_subnet.nodes.id
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
      enabled = false
    }
  }

  auto_scaler_profile {
    balance_similar_node_groups      = false
    max_graceful_termination_sec     = 600
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "3m"
    scan_interval                    = "10s"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = 0.5
  }
}

#Registry Pull Permission for the Cluster
resource "azurerm_role_assignment" "acr" {
  scope                = var.registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

# Variables
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes Version to be used in the Clusters and Nodepools"
  default = "1.21.2"
}

variable "registry_id" {
  type        = string
  description = "Default Registry of the Cluster"
  default = "/subscriptions/9278f6e1-910f-4293-bb13-c172ddb81ce4/resourceGroups/meta/providers/Microsoft.ContainerRegistry/registries/2021hackathon"
}

variable "location" {
  type        = string
  description = "Physical Location of the Resources"
  default     = "West Europe"
}
variable "node_network" {
  type = string
  description = "CIDR of the Clusters Nodes"
}

variable "prefix" {
  type        = string
  description = "Prefix for the resource names"
}

output "kubernetes_cluster" {
  value = azurerm_kubernetes_cluster.aks
}

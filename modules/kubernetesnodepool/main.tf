
resource "azurerm_kubernetes_cluster_node_pool" "nodepools" {
  name                  = var.name
  kubernetes_cluster_id = var.kubernetes_cluster.id
  vm_size               = var.vm_size
  enable_auto_scaling   = true

  vnet_subnet_id = var.kubernetes_cluster.default_node_pool.0.vnet_subnet_id

  mode      = "User"
  os_type   = var.os_type
  min_count = var.min_count
  max_count = var.max_count

  node_labels = var.labels
  node_taints = var.taints

  availability_zones = var.availability_zones

  orchestrator_version = var.kubernetes_cluster.kubernetes_version
}

variable "name" {
  type        = string
  description = "the name of the nodepool"
}
variable "kubernetes_cluster" {
  type        = any
  description = "Kubernetes Cluster Object"
}
variable "max_count" {
  type        = number
  description = "Maximum amount of Nodes in the Nodepool"
  default     = 1
}
variable "min_count" {
  type        = number
  description = "Minimum amount of Nodes in Nodepool"
  default     = 0
}
variable "os_type" {
  type        = string
  description = "Can be Linux or Windows"
  default     = "Linux"
}
variable "vm_size" {
  type        = string
  description = "Azure VM Sizes compatible with AKS"
  default     = "Standard_D1_v2"
}
variable "labels" {
  type        = map(string)
  description = "labels which are set on the nodes on kubernetes level"
  default     = {}
}
variable "taints" {
  type        = list(string)
  description = "taints which are set on the nodes on kubernetes level. eg. key=value:NoSchedule"
  default     = []
}

variable "availability_zones" {
  type        = list(string)
  description = "Overrides the default Availability Zones Please check "
  default     = [1, 2, 3]
}

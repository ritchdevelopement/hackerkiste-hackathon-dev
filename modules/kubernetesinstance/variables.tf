variable "kubernetes_version" {
  type        = string
  description = "Kubernetes Version to be used in the Clusters and Nodepools"

  default = "1.21.2"
}

variable "registry_id" {
  type        = string
  description = "Default Registry of the Cluster"
}

variable "location" {
  type        = string
  description = "Physical Location of the Resources"
  default     = "West Europe"
}

variable "networks" {
  type = object({
    internal = string
    external = string
  })
  description = "Network consisting of an Internal CIDR and an External CIDR"
}

variable "prefix" {
  type        = string
  description = "Prefix for the resource names"
}

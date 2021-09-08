# K8s-on-Azure

This Repository Contains Terraform Modules as well as an example implementation.


## Modules
The modules are split into iaas modules and paas modules.

### The IaaS Modules
This set of Modules is meant to Deploy one or multiple Cluster with everything it needs from an Infrastructure Perspective.

It contains the following Modules:
* registry
* network
* kubernetesplatform
* kubernetesinstance
* kubernetesnodepool

#### Registry Module
This module will deploy an Azure Container Registry which can be granted a Pull Permission on the AKS Clusters.
#### Network Module
The Network Module will deploy a Network based on the provided specification. It is meant to deploy VNets with "Routable" and "NATed" subnets.

#### KubernetesPlatform Module
KubernetesPlatform Deploys Application Gateways and a Loganalytics Namespace
#### KubernetesInstance Module
KubernetesInstance will deploy AKS Clusters.

#### KubernetesNodepool Module
KubernetesNodepool will deploy one or multiple Nodepools into a single or multiple Clusters.


### The PaaS Modules
The PaaS Modules are meant to deploy all Resources for setting up and maitaining the Cluster.

#### The ClusterSetup Module
This Module adds additional (Optional) Functionalities to the Cluster
* AAD Pod Identity to support Usermanaged Identities
#### The Namespace Module
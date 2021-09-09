resource "azurerm_virtual_network" "net" {
  name                = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.global.name
  address_space       = [var.networks.external, var.networks.internal]
  dns_servers         = ["1.1.1.1", "1.0.0.1", "8.8.8.8"]
}

resource "azurerm_subnet" "external" {
  name                 = format("%s%s", var.prefix, "external")
  resource_group_name  = azurerm_virtual_network.net.resource_group_name
  virtual_network_name = azurerm_virtual_network.net.name
  address_prefixes     = [var.networks.external]
}

resource "azurerm_route_table" "external" {
  name                          = format("%s%s", var.prefix, "external")
  location                      = var.location
  resource_group_name           = azurerm_virtual_network.net.resource_group_name
  disable_bgp_route_propagation = false
}

resource "azurerm_subnet_route_table_association" "external" {
  subnet_id      = azurerm_subnet.external.id
  route_table_id = azurerm_route_table.external.id

  depends_on = [
    azurerm_route_table.external,
    azurerm_subnet.external,
  ]
}

resource "azurerm_network_security_group" "external" {
  name                = format("%s%s", var.prefix, "external")
  location            = azurerm_resource_group.global.location
  resource_group_name = azurerm_resource_group.global.name
}

resource "azurerm_subnet" "internal" {
  name                 = format("%s%s", var.prefix, "internal")
  resource_group_name  = azurerm_virtual_network.net.resource_group_name
  virtual_network_name = azurerm_virtual_network.net.name
  address_prefixes     = [var.networks.internal]

  service_endpoints = ["Microsoft.AzureCosmosDB", "Microsoft.ContainerRegistry", "Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage"]
}

resource "azurerm_network_security_group" "internal" {
  name                = format("%s%s", var.prefix, "internal")
  location            = azurerm_resource_group.global.location
  resource_group_name = azurerm_resource_group.global.name
}

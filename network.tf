resource "azurerm_virtual_network" "myvnet01" {
  name                = "${var.client}-${var.prefix}-myvnet01"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "mysubnet01" {
  name                 = "${var.client}-${var.prefix}-mysubnet01"
  resource_group_name  = azurerm_resource_group.myrg.name
  address_prefixes     = ["10.0.0.0/24"]
  virtual_network_name = azurerm_virtual_network.myvnet01.name
  service_endpoints    = [var.storageac]

}

resource "azurerm_network_security_group" "mynsg01" {
  name                = "${var.client}-${var.prefix}-mynsg01"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = var.location

}








terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.100.0"
    }
  }
}

provider "azurerm" {
  features {

  }
}

resource "azurerm_resource_group" "vnet" {
  name     = var.resource_group_name
  location = var.azurerm_resource_group_location

}
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet1"
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name
  address_space       = ["10.0.0.0/16"]

}
resource "azurerm_subnet" "vnet" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.vnet.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

}

resource "azurerm_network_interface" "vnet" {
  name                = "vm-nic-${count.index + 1}"
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name
  count               = var.number_of_vm

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vnet[count.index].id
  }
  depends_on = [azurerm_virtual_network.vnet, azurerm_public_ip.vnet]
}

resource "azurerm_network_interface_security_group_association" "vnet" {
  network_interface_id      = azurerm_network_interface.vnet[count.index].id
  network_security_group_id = azurerm_network_security_group.vnet.id
  count                     = var.number_of_vm

}

resource "azurerm_windows_virtual_machine" "vnet" {
  name                = "VM-${count.index + 1}"
  resource_group_name = azurerm_resource_group.vnet.name
  location            = azurerm_resource_group.vnet.location
  size                = "Standard_F2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  count               = var.number_of_vm
  network_interface_ids = [
    azurerm_network_interface.vnet[count.index].id,
  ]

  os_disk {
    name                 = "osdisk-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"

  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  depends_on = [azurerm_network_interface.vnet]
}
resource "azurerm_public_ip" "vnet" {
  name                = "vm-ip-${count.index + 1}"
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name
  allocation_method   = "Static"
  count               = var.number_of_vm

}

resource "azurerm_network_security_group" "vnet" {
  name                = "nsg"
  location            = var.azurerm_resource_group_location
  resource_group_name = azurerm_resource_group.vnet.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}






  
output "vm_pip" {
  value = azurerm_windows_virtual_machine.vnet[*].public_ip_address
}


output "vm_private_ip" {
  value = azurerm_windows_virtual_machine.vnet[*].private_ip_address
}
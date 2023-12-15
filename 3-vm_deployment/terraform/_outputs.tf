#VM public IP used in CICD pipeline for Ansible connectivity to VM.
output "vm_pip" {  
  value = azurerm_public_ip.vm_pip.ip_address
}

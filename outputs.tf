output "admin_password" {
  description = "The admin password of the virtual machine."
  value       = local.admin_password
  sensitive   = true
}



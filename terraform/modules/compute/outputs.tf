output "instance_id" {
  value       = oci_core_instance.k3s_node.id
  description = "ID da instância K3s"
}

output "public_ip" {
  value       = oci_core_instance.k3s_node.public_ip
  description = "IP público da VM K3s"
}
output "vcn_id" {
  description = "ID da VCN criada"
  value       = oci_core_vcn.main.id
}

output "subnet_id" {
  value       = oci_core_subnet.public.id
  description = "ID da subnet pública onde as VMs do K3s serão provisionadas"
}

output "route_table_id" {
  value       = oci_core_route_table.rt.id
  description = "ID da route table responsável pelo tráfego de saída para internet"
}

output "security_list_id" {
  value       = oci_core_security_list.sl.id
  description = "ID da security list com regras de SSH e Kubernetes API"
}
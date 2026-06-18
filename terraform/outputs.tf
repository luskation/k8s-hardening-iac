output "vcn_id" {
  description = "ID da VCN criada"
  value       = module.network.vcn_id
}

output "subnet_id" {
  description = "ID da subnet pública"
  value       = module.network.subnet_id
}

output "instance_id" {
  description = "ID da instância K3s"
  value       = module.compute.instance_id
}

output "public_ip" {
  description = "IP público da instância K3s"
  value       = module.compute.public_ip
}
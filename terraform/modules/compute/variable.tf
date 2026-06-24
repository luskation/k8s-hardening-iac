variable "compartment_id" {
  type        = string
  description = "OCID do compartment onde a instância será provisionada"
}

variable "subnet_id" {
  type        = string
  description = "ID da subnet onde a VM K3s será criada"
}

variable "availability_domain" {
  type        = string
  description = "Availability Domain onde a instância será alocada"
}

variable "image_id" {
  type        = string
  description = "OCID da imagem do sistema operacional usada na VM"
}

variable "ssh_public_key" {
  type        = string
  description = "Chave pública SSH usada para acesso à instância"
}

variable "shape" {
  type        = string
  default     = "VM.Standard.A1.Flex"
  description = "Shape (tipo de máquina) da instância OCI"
}

variable "ocpus" {
  type        = number
  default     = 1
  description = "Quantidade de OCPUs para a instância Flex"
}

variable "memory_in_gbs" {
  type        = number
  default     = 6
  description = "Quantidade de memória RAM em GB para a instância Flex"
}

variable "k3s_version" {
  type        = string
  default     = "v1.29.0+k3s1"
  description = "Versão do K3s instalada automaticamente via cloud-init"
}
variable "compartment_id" {
  description = "OCID do compartimento da Oracle"
  type        = string
}

variable "ssh_public_key" {
  description = "Chave pública SSH para acesso à VM"
  type        = string
}

variable "shape" {
  description = "Shape da instância OCI"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "ocpus" {
  description = "Quantidade de OCPUs para a instância Flex"
  type        = number
  default     = 1
}

variable "memory_in_gbs" {
  description = "Memória RAM em GB para a instância Flex"
  type        = number
  default     = 6
}

variable "k3s_version" {
  description = "Versão do K3s a instalar"
  type        = string
  default     = "v1.29.0+k3s1"
}
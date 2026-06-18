variable "compartment_id" {
  description = "OCID do compartimento onde os recursos serão criados"
  type        = string
}

variable "vcn_cidr" {
  description = "Bloco CIDR da VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vcn_name" {
  description = "Nome da VCN"
  type        = string
  default     = "k3s-vcn"
}
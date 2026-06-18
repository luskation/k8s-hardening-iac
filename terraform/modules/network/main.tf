resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_id

  cidr_blocks = [
    var.vcn_cidr
  ]

  display_name = var.vcn_name

  dns_label = "k3svcn"
}
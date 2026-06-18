resource "oci_core_subnet" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id

  cidr_block   = "10.0.1.0/24"
  display_name = "k3s-public-subnet"

  route_table_id = oci_core_route_table.rt.id

  security_list_ids = [
    oci_core_security_list.sl.id
  ]

  prohibit_public_ip_on_vnic = false
}
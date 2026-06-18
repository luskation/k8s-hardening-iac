resource "oci_core_instance" "k3s_node" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain

  shape = var.shape

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  display_name = "k3s-node-1"

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
    display_name     = "k3s-vnic"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key

    user_data = base64encode(templatefile("${path.module}/cloud-init.sh", {
      k3s_version = var.k3s_version
    }))
  }
}
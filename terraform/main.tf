data "oci_identity_regions" "regions" {}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

module "network" {
  source = "./modules/network"

  compartment_id = var.compartment_id
}

module "compute" {
  source = "./modules/compute"

  compartment_id      = var.compartment_id
  subnet_id           = module.network.subnet_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  image_id            = data.oci_core_images.ubuntu.images[1].id
  ssh_public_key      = var.ssh_public_key
  shape               = var.shape
  ocpus               = var.ocpus
  memory_in_gbs       = var.memory_in_gbs
  k3s_version         = var.k3s_version
}

data "oci_core_images" "ubuntu" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
}
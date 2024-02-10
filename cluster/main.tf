terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
    }
  }
  required_version = "= 1.7.3"
}

provider "oci" {
  auth                  = "APIKey"
  tenancy_ocid          = var.tenancy_ocid
  user_ocid             = var.user_ocid
  region                = var.region
  private_key_path      = "../keys/oci_api_key.pem"
  private_key_password  = var.private_key_password
  fingerprint           = var.fingerprint
}

module "oci_free_network" {
  source = "../modules/oci_free_network"

  compartment_id = var.tenancy_ocid
  availability_domain = var.region
}

module "oci_k3s_cluster" {
    source = "../modules/oci_k3s_cluster"

    compartment_id      = module.oci_free_network.free_compartmernt_id
    tenancy_ocid        = var.tenancy_ocid 
    availability_domain = var.region
    
    control_nodes_count        = 1
    control_node_ocpus         = var.control_plane_ocpus
    control_node_memory_in_gbs = var.control_plane_memory

    worker_nodes_count        = 1
    worker_node_ocpus         = var.worker_node_ocpus
    worker_node_memory_in_gbs = var.worker_node_memory

    vcn_id                  = module.oci_free_network.vcn_id
    public_subnet_id        = module.oci_free_network.public_subnet_id
    public_subnet_cidr      = module.oci_free_network.public_subnet_cidr
    subnet_security_list_id = module.oci_free_network.subnet_security_list_id
    private_subnet_id       = module.oci_free_network.private_subnet_id  
    private_subnet_cidr     = module.oci_free_network.private_subnet_cidr
    ssh_authorized_keys     = var.ssh_authorized_keys

    linux_user               = var.linux_user
    linux_user_password_hash = var.linux_user_password_hash
}

output "external_loadbalancer_ip" {
  value = module.oci_k3s_cluster.loadbalancer_ip
}
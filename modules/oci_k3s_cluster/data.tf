data "oci_core_images" "os" { 
  compartment_id           = var.compartment_id
  operating_system         = local.operating_system
  operating_system_version = local.operating_system_version
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_identity_availability_domain" "oci_tenancy_availability_domain" {
    compartment_id = var.compartment_id
    ad_number = 1
}

data "oci_identity_compartment" "k3s_compartment" {
  id = var.compartment_id
}

#data "oci_core_vnic" "secondary_vnic_control_plane" {
#  for_each = { for i in range(var.control_nodes_count): "k3s-control-${i}" => i }
#  vnic_id = oci_core_vnic_attachment.control_plane_public_vnic["k3s-control-0"].vnic_id
#}
#
#output "test_ip" {
#  value = data.oci_core_vnic.secondary_vnic_control_plane["k3s-control-0"].private_ip_address
#}


##
## Compartment
##


resource "oci_identity_compartment" "tf_compartment" {
  # this compartment_id is the root compartment
  compartment_id = var.compartment_id
  description = "Compartment for Always Free resources."
  name = "alwaysfree"
}

###
### Network configuration
###

resource "oci_core_vcn" "virtual_cloud_network" {
    compartment_id = oci_identity_compartment.tf_compartment.id
    display_name   = "virtual cloud network" 
    cidr_block     = var.vcn_cidr_block
    dns_label   = var.vcn_dns_label
}

output "free_compartmernt_id" {
  value = oci_identity_compartment.tf_compartment.id
}

output "vcn_id" {
  value = oci_core_vcn.virtual_cloud_network.id
}

output "public_subnet_id" {
  value = oci_core_subnet.public_subnet.id
}

output "public_subnet_cidr" {
  value = oci_core_subnet.public_subnet.cidr_block
}

output "subnet_security_list_id" {
  value = oci_core_security_list.public_security_list.id
}

output "private_subnet_id" {
  value = oci_core_subnet.private_subnet.id
}

output "private_subnet_cidr" {
  value = oci_core_subnet.private_subnet.cidr_block
}

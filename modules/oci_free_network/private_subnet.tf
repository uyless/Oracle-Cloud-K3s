#resource "oci_core_subnet" "private_subnet" {
#  compartment_id      = oci_identity_compartment.tf_compartment.id
#  display_name        = "private-subnet" 
#
#  cidr_block                  = var.private_subnet_cidr_block
#  vcn_id                      = oci_core_vcn.virtual_cloud_network.id
#  dns_label                   = var.private_subnet_dns_label
#  route_table_id              = oci_core_route_table.private_route_table.id
#  security_list_ids           = [oci_core_security_list.private_security_list.id,]
#  prohibit_public_ip_on_vnic  = true
#}
#
#resource "oci_core_nat_gateway" "nat_gateway" {
#
#    compartment_id = oci_identity_compartment.tf_compartment.id
#    display_name = "NAT Gateway"
#    vcn_id          = oci_core_vcn.virtual_cloud_network.id
#}
#
#resource "oci_core_route_table" "private_route_table" {
#  compartment_id = oci_identity_compartment.tf_compartment.id
#  vcn_id         = oci_core_vcn.virtual_cloud_network.id
#  display_name   = "Private Route Table"
#
#  route_rules {
#    destination       = "0.0.0.0/0"
#    destination_type  = "CIDR_BLOCK"
#    network_entity_id = oci_core_nat_gateway.nat_gateway.id
#  }
#}
#
#resource "oci_core_security_list" "private_security_list" {
#  compartment_id = oci_identity_compartment.tf_compartment.id
#  vcn_id         = oci_core_vcn.virtual_cloud_network.id
#  display_name   = "Private Security List"
#
#  egress_security_rules {
#    description = "Allow Internet Access"
#    protocol    = "6"
#    destination = "0.0.0.0/0"
#  }
#
#  egress_security_rules {
#    description = "Allow DNS primary server"
#    protocol    = "17"
#    destination = var.dns_upstream_primary
#  }
#
#  egress_security_rules {
#    description = "Allow DNS secondary server"
#    protocol    = "17"
#    destination = var.dns_upstream_secondary
#  }   
#
#  egress_security_rules {
#    description = "Allow ICMP Reply"
#    protocol    = "1"
#    destination = "0.0.0.0/0"
#
#    # Only allow ping echo and reply
#    icmp_options {
#      type = 0
#    }
#  }
#
#  egress_security_rules {
#    description = "Allow ICMP Echo"
#    protocol    = "1"
#    destination = "0.0.0.0/0"
#
#    # Only allow ping echo and reply
#    icmp_options {
#      type = 8
#    }
#  }   
#
#  ingress_security_rules {
#    protocol = "6"
#    source   = var.private_subnet_cidr_block
#
#    tcp_options {
#      max = "6443"
#      min = "6443"
#    }
#  } 
#  
#  ingress_security_rules {
#    protocol = "6"
#    source   = var.private_subnet_cidr_block
#
#    tcp_options {
#      max = "22"
#      min = "22"
#    }   
#  }
#
#  ingress_security_rules {
#    protocol = "6"
#    source   = var.public_subnet_cidr_block
#
#    tcp_options {
#      max = "22"
#      min = "22"
#    }   
#  }    
#}
#
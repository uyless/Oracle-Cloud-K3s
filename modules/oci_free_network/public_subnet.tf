resource "oci_core_subnet" "public_subnet" {
  compartment_id      = oci_identity_compartment.tf_compartment.id
  display_name        = "public-subnet" 

  cidr_block                  = var.public_subnet_cidr_block
  vcn_id                      = oci_core_vcn.virtual_cloud_network.id
  dns_label                   = var.public_subnet_dns_label
  route_table_id              = oci_core_route_table.public_route_table.id
  security_list_ids           = [oci_core_security_list.public_security_list.id,]
  prohibit_public_ip_on_vnic  = false
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = oci_identity_compartment.tf_compartment.id
  display_name   = "Internet Gateway"
  vcn_id         = oci_core_vcn.virtual_cloud_network.id
}

resource "oci_core_route_table" "public_route_table" {
  compartment_id = oci_identity_compartment.tf_compartment.id
  vcn_id         = oci_core_vcn.virtual_cloud_network.id
  display_name   = "Public Route Table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}


resource "oci_core_security_list" "public_security_list" {
  compartment_id = oci_identity_compartment.tf_compartment.id
  vcn_id         = oci_core_vcn.virtual_cloud_network.id
  display_name   = "Public Security List"

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "80"
      min = "80"
    }
  }

  ingress_security_rules {
  protocol = "6"
  source   = "0.0.0.0/0"

    tcp_options {
      max = "443"
      min = "443"
    }
  }
}

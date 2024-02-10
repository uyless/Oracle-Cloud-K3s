data "oci_core_images" "os" { 
  compartment_id           = var.compartment_id
  operating_system         = var.operating_system
  operating_system_version = var.operating_system_version
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_identity_availability_domain" "oci_tenancy_availability_domain" {
    compartment_id = var.compartment_id
    ad_number = 1
}

###
### VM configuration
###

resource "oci_core_instance_configuration" "a1_configuration" {
    compartment_id = var.compartment_id
    
    instance_details {
      instance_type = "compute"
      block_volumes {
        attach_details {
          device = "sda"
          type = "paravirtualized"
        }
      }
    }
}

resource "oci_core_instance" "a1" {  
  availability_domain = data.oci_identity_availability_domain.oci_tenancy_availability_domain.name
  compartment_id      = var.compartment_id
  display_name        = var.hostname
  shape               = "VM.Standard.A1.Flex"

  instance_configuration_id = oci_core_instance_configuration.a1_configuration.id

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  create_vnic_details {
    display_name     = "primaryvnic"
    hostname_label   = var.hostname
    subnet_id        = var.subnet_id
    assign_public_ip = var.assign_public_ip
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.os.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data = var.user_data
  }


  lifecycle {
    ignore_changes = [
      # Ignore changes to source_details, so that instance isn't
      # recreated when a new image releases. Also allows for easy
      # resource import.
      source_details,
    ]
  }
}

data "oci_core_vnic_attachments" "a1_vnic_attachments" { 
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.a1.id
}

data "oci_core_vnic" "a1_vnic" {
  vnic_id = data.oci_core_vnic_attachments.a1_vnic_attachments.vnic_attachments[0].vnic_id
}

resource "oci_core_ipv6" "ipv6_address" {
  count   = var.assign_ipv6_address ? 1 : 0
  vnic_id = data.oci_core_vnic_attachments.a1_vnic_attachments.vnic_attachments[0].vnic_id
}

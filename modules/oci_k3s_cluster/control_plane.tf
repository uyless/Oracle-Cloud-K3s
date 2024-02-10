# Inspired by: https://github.com/inscapist/terraform-k3s-private-cloud/blob/main/k3s_master.tf
# OCI K8s Cloud controller: https://github.com/oracle/oci-cloud-controller-manager



locals {
  operating_system = "Canonical Ubuntu"
  operating_system_version = "22.04"

  control_nodes = {
    for i in range(var.control_nodes_count):
      "k3s-control-${i}" => {
        "test": "test"
      }
  }
}


###
### VM configuration
###

data "template_file" "resolv_conf" {
  template = "${file("${path.module}/user_data/resolv_conf/resolv.conf")}"
  vars = {
    oracle_nameserver    = var.dns_upstream_oracle,
    primary_nameserver   = var.dns_upstream_primary,
    secondary_nameserver = var.dns_upstream_secondary,
  }
}

data "template_file" "k3s_cloud_controller_config" {
  template = "${file("${path.module}/user_data/master/cloud_provider_oracle/config.yaml")}"
  vars = {
    compartment_id          = var.compartment_id,
    vcn_id                  = var.vcn_id,
    subnet_id               = var.public_subnet_id,
    subnet_security_list_id = var.subnet_security_list_id,
  }
}

data "template_file" "k3s_csi_controller_config" {
  template = "${file("${path.module}/user_data/master/container_storage_interface/oci-csi-controller-config.yaml")}"
  vars = {
    compartment_id          = var.compartment_id
  }
}

# https://cloudinit.readthedocs.io/en/latest/topics/format.html
data "cloudinit_config" "k3s_master" {
  for_each = { for i in range(var.control_nodes_count): "k3s-control-${i}" => i }

  gzip          = true
  base64_encode = true

  # Debug with:
  # cat /var/log/cloud-init.log
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/user_data/generic_cloud_config.yaml", {
      secondary_vnic_service  = filebase64("${path.module}/user_data/additional_vnics/vnics.service")
      secondary_vnic_timer    = filebase64("${path.module}/user_data/additional_vnics/vnics.timer")
      resolv_conf             = base64encode(data.template_file.resolv_conf.rendered)
      user_name               = var.linux_user
      user_password_hash      = var.linux_user_password_hash
      ssh_key                 = var.ssh_authorized_keys
    })
  }

  # merge types: https://cloudinit.readthedocs.io/en/20.1/topics/merging.html#built-in-mergers
  part {
    filename     = "k3s_init.cfg"
    content_type = "text/cloud-config"
    merge_type   = "list(append)+dict(recurse_array)+str()"
    content = templatefile("${path.module}/user_data/master/control_cloud_config.yaml", {
      cloud_controller_config_secret_yaml = base64encode(data.template_file.k3s_cloud_controller_config.rendered)
      cloud_controller_daemonset_yaml     = filebase64("${path.module}/user_data/master/cloud_provider_oracle/daemonset.yaml")
      cloud_controller_rbac_yaml          = filebase64("${path.module}/user_data/master/cloud_provider_oracle/rbac.yaml")
      csi_controller_config_secret_yaml   = base64encode(data.template_file.k3s_csi_controller_config.rendered)
      csi_controller_driver_yaml          = filebase64("${path.module}/user_data/master/container_storage_interface/oci-csi-controller-driver.yaml")
      csi_node_driver_yaml                = filebase64("${path.module}/user_data/master/container_storage_interface/oci-csi-node-driver.yaml")
      csi_node_rbac_yaml                  = filebase64("${path.module}/user_data/master/container_storage_interface/oci-csi-node-rbac.yaml")
      storage_class                       = filebase64("${path.module}/user_data/master/container_storage_interface/storage-class.yaml")
    })
  }  

  # Debug with:
  # cat /tmp/k3s-server-install-debug.log
  # Generated code can be found in /var/lib/cloud/instance/scripts (for debugging purpose)
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/user_data/master/k3s_server_install.sh", {
      cluster_token           = random_password.cluster_token.result,
      control_node_private_ip = var.private_subnet_cidr != "" ? cidrhost(var.private_subnet_cidr, 2 + each.value) : cidrhost(var.public_subnet_cidr, 2 + each.value),
      private_network         = var.private_subnet_cidr,
      public_network          = var.public_subnet_cidr,
      k3s_version             = var.k3s_version
    })
  }
}

#resource "oci_core_instance_configuration" "control_plane_instance_configuration" {
#  compartment_id = var.compartment_id
#  display_name = "k3s_control_plane"
#
#
#  instance_details {
#    instance_type = "compute"
#
#    launch_details {
#      compartment_id      = var.compartment_id
#      shape               = "VM.Standard.A1.Flex"
#      availability_domain = data.oci_identity_availability_domain.oci_tenancy_availability_domain.name
#
#      shape_config {
#        ocpus         = var.control_node_ocpus
#        memory_in_gbs = var.control_node_memory_in_gbs
#      }
#
#      create_vnic_details {
#        display_name     = "primaryvnic"
#        subnet_id        = var.public_subnet_id
#        assign_public_ip = true
#      }
#    
#      source_details {
#        source_type = "image"
#        image_id    = lookup(data.oci_core_images.os.images[0], "id")
#
#        boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
#      }
#
#      #launch_options {
#      #  boot_volume_type = "ISCSI"
#      #}
#    }
#  }
#
#  lifecycle {
#    create_before_destroy = true
#  }
#}

resource "oci_core_instance" "control_plane_instance" {  
  for_each = { for i in range(var.control_nodes_count): "k3s-control-${i}" => i }
  
  availability_domain = data.oci_identity_availability_domain.oci_tenancy_availability_domain.name
  compartment_id      = var.compartment_id
  display_name        = each.key

  # There is a bug when using configuration ID. It returns 404 for an unknown reason
  #instance_configuration_id = oci_core_instance_configuration.control_plane_instance_configuration.id

  shape               = "VM.Standard.A1.Flex"
  shape_config {
    ocpus         = var.control_node_ocpus
    memory_in_gbs = var.control_node_memory_in_gbs
  }

  create_vnic_details {
    display_name           = "public nic"
    hostname_label         = each.key
    subnet_id              = var.public_subnet_id
    assign_public_ip       = false
    private_ip             = cidrhost(var.public_subnet_cidr, 2 + each.value)
    skip_source_dest_check = false
  } 

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.os.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data = data.cloudinit_config.k3s_master[each.key].rendered
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to source_details, so that instance isn't
      # recreated when a new image releases. Also allows for easy
      # resource import.
      source_details["image_id"]
      
    ]
  }
}

#resource "oci_core_vnic_attachment" "control_plane_public_vnic" {
#    for_each = { for i in range(var.control_nodes_count): "k3s-control-${i}" => i }
#
#    create_vnic_details {
#        assign_public_ip = false
#        display_name = "secondary interface public"
#        hostname_label = each.key
#        skip_source_dest_check = false
#        subnet_id = var.public_subnet_id
#        private_ip = cidrhost(var.public_subnet_cidr, 2 + each.value)   
#    }
#    instance_id = oci_core_instance.control_plane_instance[each.key].id
#
#    #Optional
#    display_name = "secondary interface public"
#}

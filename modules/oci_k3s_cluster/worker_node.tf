# Inspired by: https://github.com/inscapist/terraform-k3s-private-cloud/blob/main/k3s_master.tf
# OCI K8s Cloud controller: https://github.com/oracle/oci-cloud-controller-manager


###
### VM configuration
###

# https://cloudinit.readthedocs.io/en/latest/topics/format.html
data "cloudinit_config" "k3s_node" {
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

  # Debug with:
  # cat /tmp/k3s-server-install-debug.log
  # Generated code can be found in /var/lib/cloud/instance/scripts (for debugging purpose)
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/user_data/node/k3s_node_install.sh", {
      cluster_token = random_password.cluster_token.result,
      cluster_server = oci_core_instance.control_plane_instance["k3s-control-0"].private_ip,
      k3s_version    = var.k3s_version,
    })
  }
}


resource "oci_core_instance" "worker_node_instance" {  
  for_each = { for i in range(var.worker_nodes_count): "k3s-worker-${i}" => i }
  
  availability_domain = data.oci_identity_availability_domain.oci_tenancy_availability_domain.name
  compartment_id      = var.compartment_id
  display_name        = each.key

  # There is a bug when using configuration ID. It returns 404 for an unknown reason
  #instance_configuration_id = oci_core_instance_configuration.control_plane_instance_configuration.id

  shape               = "VM.Standard.A1.Flex"
  shape_config {
    ocpus         = var.worker_node_ocpus
    memory_in_gbs = var.worker_node_memory_in_gbs
  }

  create_vnic_details {
    display_name           = "public-nic"
    hostname_label         = each.key
    subnet_id              = var.public_subnet_id
    assign_public_ip       = false
    private_ip             = cidrhost(var.public_subnet_cidr, 10 + each.value)
    skip_source_dest_check = true
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.os.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data = data.cloudinit_config.k3s_node.rendered
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

#resource "oci_core_vnic_attachment" "worker_node_public_vnic" {
#    for_each = { for i in range(var.worker_nodes_count): "k3s-worker-${i}" => i }
#
#    create_vnic_details {
#        assign_public_ip       = false
#        display_name           = "public vnic"
#        hostname_label         = each.key
#        skip_source_dest_check = true
#        subnet_id              = var.public_subnet_id
#        private_ip             = cidrhost(var.public_subnet_cidr, 10 + each.value)
#    }
#    instance_id = oci_core_instance.worker_node_instance[each.key].id
#
#    #Optional
#    display_name = "public vnic"
#}

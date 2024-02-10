locals {
  external_ip = [ for ip_address_hash in oci_load_balancer_load_balancer.k3s_load_balancer.ip_address_details : 
    [
        ip_address_hash.ip_address,
    ] if ip_address_hash.is_public == true ]
}

resource "oci_load_balancer_load_balancer" "k3s_load_balancer" {
    #Required
    compartment_id = var.compartment_id
    display_name = "K3s Loadbalancer"
    subnet_ids = [ var.public_subnet_id ]

    is_private = false

    shape = "flexible"
    shape_details {
      maximum_bandwidth_in_mbps = 10
      minimum_bandwidth_in_mbps = 10
    }
}

resource "oci_load_balancer_backend_set" "ssh_control_backend_set" {
    for_each = { for i in range(var.control_nodes_count): "k3s-control-${i}" => i }
    
    health_checker {
        #Required
        protocol = "TCP"

        #Optional
        interval_ms = 10000
        port = 22
        retries = 3
        timeout_in_millis = 3000
    }
    load_balancer_id = oci_load_balancer_load_balancer.k3s_load_balancer.id
    name = "ssh-${each.key}"
    policy = "LEAST_CONNECTIONS"
}

resource "oci_load_balancer_backend" "ssh_control_backend" {
    for_each = { for i in range(var.control_nodes_count): "k3s-control-${i}" => i }
   
    #Required
    backendset_name = oci_load_balancer_backend_set.ssh_control_backend_set[each.key].name
    load_balancer_id = oci_load_balancer_load_balancer.k3s_load_balancer.id
    
    ip_address = oci_core_instance.control_plane_instance[each.key].private_ip
    port = "22"
}

resource "oci_load_balancer_listener" "ssh_listener" {
    for_each = { for i in range(var.control_nodes_count): "k3s-control-${i}" => i }

    default_backend_set_name = oci_load_balancer_backend_set.ssh_control_backend_set[each.key].name
    load_balancer_id = oci_load_balancer_load_balancer.k3s_load_balancer.id
    name = "ssh-${each.key}"
    port = 22
    protocol = "TCP"
}

output "loadbalancer_ip" {
  value = local.external_ip[0][0]
}

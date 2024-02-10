resource "oci_identity_dynamic_group" "k3s_dynamic_group" {
    compartment_id = var.tenancy_ocid
    description = "Dynamic Group for k3s oracle cloud controller"
    matching_rule = "instance.compartment.id = '${var.compartment_id}'"
    name = "k3s_dynamic_group"
}

# Maybe Allow dynamic-group id ocid1.dynamicgroup.oc1..aaaaaaaalccieiyzz3e3kr65wyjbpxsmy4p7carwnzu2quivlume66nhpgoq to manage instance-family in compartment alwaysfree
resource "oci_identity_policy" "k3s_cloud_controller_policy" {
    #Required
    compartment_id = var.compartment_id
    description = "Policies needed for the cloud controller to work with instance principials"
    name = "k3s_cloud_controller_policy"
    statements = [
        "Allow dynamic-group ${oci_identity_dynamic_group.k3s_dynamic_group.name} to manage instance-family in compartment ${data.oci_identity_compartment.k3s_compartment.name}",
        "Allow dynamic-group ${oci_identity_dynamic_group.k3s_dynamic_group.name} to use virtual-network-family in compartment ${data.oci_identity_compartment.k3s_compartment.name}",
        "Allow dynamic-group ${oci_identity_dynamic_group.k3s_dynamic_group.name} to manage load-balancers in compartment ${data.oci_identity_compartment.k3s_compartment.name}",
        "Allow dynamic-group ${oci_identity_dynamic_group.k3s_dynamic_group.name} to manage security-lists in compartment ${data.oci_identity_compartment.k3s_compartment.name}",
        "Allow dynamic-group ${oci_identity_dynamic_group.k3s_dynamic_group.name} to manage volume-family in compartment ${data.oci_identity_compartment.k3s_compartment.name}",
    ]
}
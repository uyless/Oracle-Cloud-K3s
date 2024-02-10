variable "tenancy_ocid" {
    type        = string
    description = "https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five"
}
variable "user_ocid" {
    type        = string
    description = "https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five"
}
variable "fingerprint" {
    type = string
    description = "Fingerprint of public key. see https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#Required_Keys_and_OCIDs"
}
variable "private_key_path" {
    type        = string
    default     = "../keys/oci_api_key.pem"
}
variable "private_key_password" {
    type        = string
}
variable "region" {
    type        = string
    default     = "eu-frankfurt-1"
    description = "An OCI region. See https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm#top"
}
variable "control_plane_ocpus" {
  type        = number
  default     = 2
  description = "CPU count for control plane nodes"
}
variable "control_plane_memory" {
  type        = number
  default     = 6
  description = "RAM for control plane nodes in Gigabytes"
}
variable "worker_node_ocpus" {
  type        = number
  default     = 2
  description = "CPU count for worker nodes"
}
variable "worker_node_memory" {
  type        = number
  default     = 6
  description = "RAM for worker nodes in Gigabytes"
}
variable "ssh_authorized_keys" {
  type = string
  description = "SSH public key for accessing k3s nodes"
}
variable "linux_user" {
  description = "Linux user to be created as admin"
  type        = string
}
variable "linux_user_password_hash" {
  description = "Linux user password hash"
  type        = string
}

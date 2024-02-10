variable "control_nodes_count" {
  description = "Count of control plane nodes"
  default     = 1
  type        = number
}

variable "worker_nodes_count" {
  description = "Count of worker nodes"
  default     = 1
  type        = number
}

variable "control_node_ocpus" {
  description = "The number of OCPUs to assign to the instance. Must be between 1 and 4."
  type        = number
  default     = 3

  validation {
    condition     = var.control_node_ocpus >= 1
    error_message = "The value of ocpus must be greater than or equal to 1."
  }

  validation {
    condition     = var.control_node_ocpus <= 4
    error_message = "The value of ocpus must be less than or equal to 4 to remain in the free tier."
  }
}

variable "control_node_memory_in_gbs" {
  description = "The amount of memory in GB to assign to the instance. Must be between 1 and 24."
  default     = 6

  validation {
    condition     = var.control_node_memory_in_gbs >= 1
    error_message = "The value of memory_in_gbs must be greater than or equal to 1."
  }

  validation {
    condition     = var.control_node_memory_in_gbs <= 24
    error_message = "The value of memory_in_gbs must be less than or equal to 24 to remain in the free tier."
  }
}

variable "worker_node_ocpus" {
  description = "The number of OCPUs to assign to the instance. Must be between 1 and 4."
  type        = number
  default     = 3

  validation {
    condition     = var.worker_node_ocpus >= 1
    error_message = "The value of ocpus must be greater than or equal to 1."
  }

  validation {
    condition     = var.worker_node_ocpus <= 4
    error_message = "The value of ocpus must be less than or equal to 4 to remain in the free tier."
  }
}

variable "worker_node_memory_in_gbs" {
  description = "The amount of memory in GB to assign to the instance. Must be between 1 and 24."
  default     = 6

  validation {
    condition     = var.worker_node_memory_in_gbs >= 1
    error_message = "The value of memory_in_gbs must be greater than or equal to 1."
  }

  validation {
    condition     = var.worker_node_memory_in_gbs <= 24
    error_message = "The value of memory_in_gbs must be less than or equal to 24 to remain in the free tier."
  }
}

variable "boot_volume_size_in_gbs" {
  description = "A custom size for the boot volume. Must be between 50 and 200. If not set, defaults to the size of the image which is around 46 GB."
  default     = null

  validation {
    condition     = var.boot_volume_size_in_gbs == null ? true : var.boot_volume_size_in_gbs >= 50
    error_message = "The value of boot_volume_size_in_gbs must be greater than or equal to 50."
  }

  validation {
    condition     = var.boot_volume_size_in_gbs == null ? true : var.boot_volume_size_in_gbs <= 200
    error_message = "The value of boot_volume_size_in_gbs must be less than or equal to 200 to remain in the free tier."
  }
}

variable "compartment_id" {
  description = "The OCID of the compartment containing the instance."
  type        = string
}

variable "tenancy_ocid" {
  description = "Tenacy ID needed for creating dynamic groups"
  type        = string
}

variable "vcn_id" {
  description = "VCN id needed for k3s cloud controller to work"
  type        = string
}

variable "availability_domain" {
  description = "The availability domain of the instance."
  type        = string
}

variable "private_subnet_id" {
  description = "The OCID of the subnet to create the VNIC in."
  type        = string
}

variable "private_subnet_cidr" {
  description = "The cidr of private subnet"
  type        = string
}

variable "public_subnet_id" {
  description = "The OCID of the subnet to create the VNIC in."
  type        = string
}

variable "public_subnet_cidr" {
  description = "The cidr of private subnet"
  type        = string
}

variable "subnet_security_list_id" {
  description = "The OCID of the security list added to public subnet and configured by k8s cloud provider"
  type        = string
}

variable "ssh_authorized_keys" {
  description = "The public SSH key(s) that should be authorized for the default user."
  type        = string
}

variable "assign_ipv6_address" {
  description = "Whether or not an IPv6 address should be assigned to the instance. Requires a subnet with IPv6 enabled. Defaults to `false`."
  type        = bool
  default     = false
}

variable "linux_user" {
  description = "Linux user to be created as admin"
  type        = string
}

variable "linux_user_password_hash" {
  description = "Linux user password hash"
  type        = string
}

# https://www.suse.com/suse-k3s/support-matrix/all-supported-versions/k3s-v1-26/
variable "k3s_version" {
  description = "K3s kubernetes version to use"
  default     = "v1.26.8+k3s1"
}

variable "dns_upstream_oracle" {
  default = "169.254.169.254"
  type    = string
}

variable "dns_upstream_primary" {
  default = "1.1.1.1"
  type    = string
}

variable "dns_upstream_secondary" {
  default = "1.0.0.1"
  type    = string
}

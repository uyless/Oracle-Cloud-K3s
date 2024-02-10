variable "compartment_id" {
  description = "The OCID of the compartment containing the instance."
  type        = string
}

variable "availability_domain" {
  description = "The availability domain of the instance."
  type        = string
}

variable "vcn_dns_label" {
  default     = "vcn"
  type        = string
  description = "Should only consist of letters and numbers! Will form fqdn like <host>.<subnet>.<vcn>.oraclevcn.com"
}

variable "public_subnet_dns_label" {
  default     = "public"
  type        = string
  description = "Should only consist of letters and numbers! Will form fqdn like <host>.<subnet>.<vcn>.oraclevcn.com"
}

variable "private_subnet_dns_label" {
  default     = "private"
  type        = string
  description = "Should only consist of letters and numbers! Will form fqdn like <host>.<subnet>.<vcn>.oraclevcn.com"
}

variable "vcn_cidr_block" {
  default = "10.16.0.0/16"
  type    = string
}

variable "public_subnet_cidr_block" {
  default = "10.16.0.0/24"
  type    = string
}

variable "private_subnet_cidr_block" {
  default = "10.16.1.0/24"
  type    = string
}

variable "dns_upstream_primary" {
  default = "1.1.1.1/32"
  type    = string
}

variable "dns_upstream_secondary" {
  default = "1.0.0.1/32"
  type    = string
}

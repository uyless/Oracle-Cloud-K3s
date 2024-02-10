terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=5.28.0"
    }
  }
  required_version = ">= 1.0.0"
}

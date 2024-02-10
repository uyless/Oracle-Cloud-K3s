# Terraform project to setup oracle free tier vms

## Prepare oracle keys

You will have to create a key pair for oracle cloud. Get the oci command line tool.

More information [here](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#InstallingCLI__linux_and_unix).

```bash
# Create oci config folder
mkdir ~/.oci

# Create key pair with passphrase
openssl genrsa -out ~/.oci/oci_api_key.pem -aes128 2048        
chmod go-rwx ~/.oci/oci_api_key.pem
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
cat ~/.oci/oci_api_key_public.pem

# Copy private key to local terraform


# Get fingerprint
openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c
```

Upload the public key afterwards in the profile of the user which oicd will be used. [More information here](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#three)

## Prepare run

```bash
 export TF_VAR_tenancy_ocid="<get from keepass 'terraform oracle tenacy ocid'>"
 export TF_VAR_user_ocid="<get from keepass 'terraform oracle user ocid'>"
 export TF_VAR_fingerprint="<get from keepass 'terraform oracle public key fingerprint'>"
 export TF_VAR_private_key_password="<get from keepass 'terraform oracle private key passphrase'>"
 export TF_VAR_linux_user="<get user from keepass 'terraform k3s linux user'>"
 export TF_VAR_linux_user_password_hash="<get password from keepass 'terraform k3s linux user'>"
```
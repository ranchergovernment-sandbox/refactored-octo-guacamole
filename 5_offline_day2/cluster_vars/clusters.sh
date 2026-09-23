#!/bin/bash

#paths
export domain=lab.randalllabs.com
export cacert_path=/mnt/development/certs/ca.crt
export cacert=`cat ${cacert_path} | base64 | tr -d "\n"`
export cert_path=/mnt/development/certs/${domain}.crt
export cert_b64=`cat ${cert_path} | base64 | tr -d "\n"`
export key_path=/mnt/development/certs/${domain}.key
export key_b64=`cat ${key_path} | base64 | tr -d "\n"`

#ansible vars
export ansible_ssh_user=cloud-user
export ansible_ssh_key=~/.ssh/id_rsa

#registry vars
export offline_registry=harbor.lab.randalllabs.com
#export offline_registry_user=<null>  #we are currently unauthenticated
#export offline_registry_pass=<null>  #we are currently unauthenticated



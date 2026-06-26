#!/bin/bash

. ./env.sh
. ../versions

sync_product argo-cd ${ARGO_CD_VERSION}
sync_product cert-manager ${CERT_MANAGER_VERSION}
sync_product grafana ${GRAFANA_VERSION}
sync_product harbor ${HARBOR_VERSION}
sync_product mariadb ${MARIADB_VERSION}
sync_product kubernetes-csi-driver-nfs ${KUBERNETES_CSI_DRIVER_NFS_VERSION}
sync_product minio ${MINIO_VERSION}
sync_product prometheus ${PROMETHEUS_VERSION}
sync_product prometheus-operator ${PROMETHEUS_OPERATOR_VERSION}
sync_product ollama ${OLLAMA_VERSION}
sync_product open-webui ${OPEN_WEBUI_VERSION}
sync_product keycloak ${KEYCLOAK_VERSION}

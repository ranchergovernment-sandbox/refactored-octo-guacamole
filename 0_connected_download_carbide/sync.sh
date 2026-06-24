#!/bin/bash

. ../env.sh
. ../versions

sync_product rke2 ${RKE2_VERSION}

sync_product rancher ${RANCHER_VERSION}
sync_charts rancher rancher ${RANCHER_CHART_VERSION} oci://registry.ranchercarbide.dev/carbide-charts/rancher

sync_product airgapped-docs ${AIRGAP_DOCS_VERSION}
sync_charts airgapped-docs airgapped-docs ${AIRGAP_DOCS_CHART_VERSION} oci://registry.ranchercarbide.dev/carbide-charts

sync_product cert-manager ${CERT_MANAGER_VERSION}
sync_charts cert-manager cert-manager ${CERT_MANAGER_CHART_VERSION} oci://quay.io/jetstack/charts

sync_product harvester ${HARVESTER_VERSION}

sync_product longhorn ${LONGHORN_VERSION}
sync_charts longhorn longhorn ${LONGHORN_CHART_VERSION} https://charts.longhorn.io

sync_product neuvector ${NEUVECTOR_VERSION}
sync_charts neuvector core ${NEUVECTOR_CORE_CHART_VERSION} https://neuvector.github.io/neuvector-helm
sync_charts neuvector crd ${NEUVECTOR_CRD_CHART_VERSION} https://neuvector.github.io/neuvector-helm
sync_charts neuvector monitor ${NEUVECTOR_MONITOR_CHART_VERSION} https://neuvector.github.io/neuvector-helm

sync_product kubewarden kubewarden-controller-${KUBEWARDEN_CONTROLLER_VERSION} https://charts.kubewarden.io
sync_charts kubewarden kubewarden-controller ${KUBEWARDEN_CONTROLLER_CHART_VERSION} https://charts.kubewarden.io
envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/01-cert-manager-install.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  namespace: kube-system
  name: cert-manager
spec:
  targetNamespace: cert-manager
  createNamespace: true
  insecureSkipTLSVerify: true
  chart: oci://${offline_registry}/hauler/cert-manager
  version: "v1.16.2"
  valuesContent: |-
    crds:
      enabled: true
EOF

envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/02-cert-manager-values.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: cert-manager
  namespace: kube-system
spec:
  valuesContent: |-
    image:
      registry: ${offline_registry}
      repository: jetstack/cert-manager-controller

    webhook:
      image:
        registry: ${offline_registry}
        repository: jetstack/cert-manager-webhook

    cainjector:
      image:
        registry: ${offline_registry}
        repository: jetstack/cert-manager-cainjector

    startupapicheck:
      image:
        registry: ${offline_registry}
        repository: jetstack/cert-manager-startupapicheck

    acmesolver:
      image:
        registry: ${offline_registry}
        repository: jetstack/cert-manager-acmesolver
EOF


envsubst <<EOF > docs/${cluster_name}/post-deploy-manifests/03-cert-manager-cluster-issuer.yaml
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
  namespace: cert-manager
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: selfsigned-ca
  namespace: cert-manager
spec:
  isCA: true
  commonName: selfsigned-root-ca
  secretName: root-ca-secret
  duration: 52596h
  renewBefore: 43830h
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: selfsigned-issuer
    kind: ClusterIssuer
    group: cert-manager.io
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: cluster-issuer
spec:
  ca:
    secretName: root-ca-secret
EOF

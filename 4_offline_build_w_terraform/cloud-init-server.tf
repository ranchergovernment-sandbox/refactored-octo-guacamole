resource "harvester_cloudinit_secret" "cloud-config-rke2-server" {
  name = "cloud-config-rke2-server"
  namespace = "${var.cluster_namespace}"

  user_data = <<-EOF
    #cloud-config
    chpasswd:
      expire: false
    ssh_pwauth: true
    write_files:
      - path: /var/lib/rancher/rke2/server/manifests/00-traefik-values.yaml
        permissions: '644'
        content: |
          apiVersion: helm.cattle.io/v1
          kind: HelmChartConfig
          metadata:
            name: rke2-traefik
            namespace: kube-system
          spec:
            valuesContent: |-
              additionalArguments:
                - "--entryPoints.websecure.transport.respondingTimeouts.readTimeout=0"
              ports:
                web:
                  redirections:
                    entryPoint:
                      to: websecure
                      scheme: https
                websecure:
                  expose:
                    default: true
                  port: 443
                  tls:
                    enabled: true

      - path: /var/lib/rancher/rke2/server/manifests/20-offline-charts.yaml
        permissions: '644'
        content: | 
          ---
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: ui-plugin-catalog
            namespace: cattle-ui-plugin-system
            labels:
              catalog.cattle.io/ui-extensions-catalog-image: ui-plugin-catalog
          spec:
            replicas: 1
            selector:
              matchLabels:
                catalog.cattle.io/ui-extensions-catalog-image: ui-plugin-catalog
            template:
              metadata:
                namespace: cattle-ui-plugin-system
                labels:
                  catalog.cattle.io/ui-extensions-catalog-image: ui-plugin-catalog
              spec:
                containers:
                - name: server
                  image: ${var.system_default_registry}/rancher/ui-plugin-catalog:${var.ui-plugin-catalog_version}
                  imagePullPolicy: IfNotPresent
          ---
          apiVersion: v1
          kind: Service
          metadata:
            name: ui-plugin-catalog-svc
            namespace: cattle-ui-plugin-system
          spec:
            ports:
              - name: catalog-svc-port
                port: 8080
                protocol: TCP
                targetPort: 8080
            selector:
              catalog.cattle.io/ui-extensions-catalog-image: ui-plugin-catalog
            type: ClusterIP
          ---
          apiVersion: catalog.cattle.io/v1
          kind: ClusterRepo
          metadata:
            name: ui-plugin-catalog-repo
          spec:
            url: http://ui-plugin-catalog-svc.cattle-ui-plugin-system:8080
          ---
      
      - path: /var/lib/rancher/rke2/server/manifests/10-mcm-install.yaml
        permissions: '644'
        content: | 
          apiVersion: helm.cattle.io/v1
          kind: HelmChart
          metadata:
            namespace: kube-system
            name: rancher
          spec:
            targetNamespace: cattle-system
            createNamespace: true
            insecureSkipTLSVerify: true
            chart: oci://${var.system_default_registry}/hauler/rancher
            version: ${var.rancher_version}

      - path: /var/lib/rancher/rke2/server/manifests/10-mcm-values.yaml
        permissions: '644'
        content: | 
          apiVersion: helm.cattle.io/v1
          kind: HelmChartConfig
          metadata:
            name: rancher
            namespace: kube-system
          spec:
            valuesContent: |-
              rancherImage: ${var.system_default_registry}/rancher/rancher
              systemDefaultRegistry: ${var.system_default_registry}
              hostname: ${var.rancher_fqdn}
              bootstrapPassword: "admin"
              ingress:
                tls:
                  source: "rancher"
              useBundledSystemChart: "true"
              extraEnv:
              - name: CATTLE_RKE_METADATA_CONFIG
                value: '{"refresh-interval-minutes":"0","url":"https://releases.rancher.com/kontainer-driver-metadata/release-${var.rancher_version}/data.json"}'


      - path: /var/lib/rancher/rke2/server/manifests/02-cluster-issuer.yaml
        permissions: '644'
        content: | 
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

      - path: /var/lib/rancher/rke2/server/manifests/01-cert-manager-install.yaml
        permissions: '644'
        content: | 
          apiVersion: helm.cattle.io/v1
          kind: HelmChart
          metadata:
            namespace: kube-system
            name: cert-manager
          spec:
            targetNamespace: cert-manager
            createNamespace: true
            insecureSkipTLSVerify: true
            chart: oci://${var.system_default_registry}/hauler/cert-manager
            version: "v1.20.2"
            valuesContent: |-
              crds:
                enabled: true

      - path: /var/lib/rancher/rke2/server/manifests/10-cert-manager-values.yaml
        permissions: '644'
        content: | 
          apiVersion: helm.cattle.io/v1
          kind: HelmChartConfig
          metadata:
            name: cert-manager
            namespace: kube-system
          spec:
            valuesContent: |-
              image:
                registry: ${var.system_default_registry}
                repository: containers/cert-manager-controller
              
              webhook:
                image:
                  registry: ${var.system_default_registry}
                  repository: containers/cert-manager-webhook
              
              cainjector:
                image:
                  registry: ${var.system_default_registry}
                  repository: containers/cert-manager-cainjector
              
              startupapicheck:
                image:
                  registry: ${var.system_default_registry}
                  repository: containers/cert-manager-startupapicheck

              acmesolver:
                image:
                  registry: ${var.system_default_registry}
                  repository: containers/cert-manager-acmesolver

      - path: /var/lib/rancher/rke2/server/manifests/01-kubevip-install.yaml
        permissions: '644'
        content: | 
          apiVersion: helm.cattle.io/v1
          kind: HelmChart
          metadata:
            namespace: kube-system
            name: kube-vip
          spec:
            targetNamespace: kube-system
            insecureSkipTLSVerify: true
            chart: oci://${var.system_default_registry}/hauler/kube-vip
            version: "0.9.1"
            valuesContent: |-
              config:
                address: ${var.lb_ip}
              env:
                vip_interface: ${var.lb_if}
                cp_enable: "true"
                lb_enable: "false"
                vip_leaderelection: "true"


      - path: /var/lib/rancher/rke2/server/manifests/100-dod-banner.yaml
        permissions: '644'
        content: | 
          ---
          apiVersion: management.cattle.io/v3
          customized: false
          default: '{}'
          kind: Setting
          metadata:
            name: ui-banners
          source: ""
          value: '{"loginError":{"message":"","showMessage":"false"},"bannerHeader":{"background":"#26a269","color":"#141419","textAlignment":"center","fontWeight":null,"fontStyle":null,"fontSize":"10px","textDecoration":null,"text":"UNCLASSIFIED//FOUO"},"bannerFooter":{"background":"#eeeff4","color":"#141419","textAlignment":"center","fontWeight":null,"fontStyle":null,"fontSize":"14px","textDecoration":null,"text":null},"bannerConsent":{"background":"#eeeff4","color":"#141419","textAlignment":"left","fontWeight":null,"fontStyle":null,"fontSize":"14px","textDecoration":null,"text":"                You
            are accessing a U.S. Government (USG) Information System (IS) that is provided for
            USG-authorized use only. By using this IS (which includes any device attached to
            this IS), you consent to the following conditions:\\n\\n\n                - The
            USG routinely intercepts and monitors communications on this IS for purposes including,
            but not limited to, penetration testing, COMSEC monitoring, network operations and
            defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence
            (CI) investigations.\\n\n                - At any time, the USG may inspect and
            seize data stored on this IS.\\n\n                - Communications using, or data
            stored on, this IS are not private, are subject to routine monitoring, interception,
            and search, and may be disclosed or used for any USG authorized purpose.\\n\n                -
            This IS includes security measures (e.g., authentication and access controls) to
            protect USG interests--not for your personal benefit or privacy.\\n\n                -
            Notwithstanding the above, using this IS does not constitute consent to PM, LE or
            CI investigative searching or monitoring of the content of privileged communications,
            or work product, related to personal representation or services by attorneys, psychotherapists,
            or clergy, and their assistants. Such communications and work product are private
            and confidential. See User Agreement for details.","button":"ACCEPT"},"showHeader":"true","showFooter":"false","showConsent":"true"}'


      - path: /etc/rancher/rke2/config.yaml
        permissions: '644'
        content: | 
          token: ${var.join_token}
          system-default-registry: "${var.system_default_registry}"
          ingress-controller: traefik
          profile: "cis"
          selinux: true
          secrets-encryption: true
          write-kubeconfig-mode: "0640"
          kube-controller-manager-arg:
          - bind-address=127.0.0.1
          - use-service-account-credentials=true
          - tls-min-version=VersionTLS12
          - tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
          kube-scheduler-arg: 
          - tls-min-version=VersionTLS12
          - tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
          kube-apiserver-arg: 
          - tls-min-version=VersionTLS12
          - tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
          - authorization-mode=RBAC,Node
          - anonymous-auth=false
          - audit-log-mode=blocking-strict
          - audit-log-maxage=30
          - admission-control-config-file=/etc/rancher/rke2/pod-security-admission-config.yaml
          kubelet-arg:
          - protect-kernel-defaults=true
          - read-only-port=0
          - authorization-mode=Webhook
          - streaming-connection-idle-timeout=5m

      - path: /etc/rancher/rke2/registries.yaml
        permissions: '0644'
        content: |
          mirrors:
            "*":
               endpoint:
                 - https://${var.system_default_registry}
          configs:
            "https://${var.system_default_registry}":

      - path: /etc/rancher/rke2/audit-policy.yaml
        permissions: '644'
        content: | 
          ---
          apiVersion: audit.k8s.io/v1
          kind: Policy
          rules:
            # Log changes at RequestResponse level
            # See https://kubernetes.io/docs/tasks/debug-application-cluster/audit/
            - level: RequestResponse
      - path: /etc/rancher/rke2/pod-security-admission-config.yaml
        permissions: '644'
        content: | 
          # This sample list was generated from:
          # https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/authentication-permissions-and-global-configuration/psa-config-templates#exempting-required-rancher-namespaces
          # For security reasons, this list should be as concise as possible
          # only include active namespaces that need to be except from a restricted profile.
          
          ---
          apiVersion: apiserver.config.k8s.io/v1
          kind: AdmissionConfiguration
          plugins:
            - name: PodSecurity
              configuration:
                apiVersion: pod-security.admission.config.k8s.io/v1
                kind: PodSecurityConfiguration
                defaults:
                  enforce: "restricted"
                  enforce-version: "latest"
                  audit: "restricted"
                  audit-version: "latest"
                  warn: "restricted"
                  warn-version: "latest"
                exemptions:
                  usernames: []
                  runtimeClasses: []
                  namespaces: [calico-apiserver,
                               calico-system,
                               cattle-alerting,
                               cattle-csp-adapter-system,
                               cattle-elemental-system,
                               cattle-epinio-system,
                               cattle-externalip-system,
                               cattle-fleet-local-system,
                               cattle-fleet-system,
                               cattle-gatekeeper-system,
                               cattle-global-data,
                               cattle-global-nt,
                               cattle-impersonation-system,
                               cattle-istio,
                               cattle-istio-system,
                               cattle-logging,
                               cattle-logging-system,
                               cattle-monitoring-system,
                               cattle-neuvector-system,
                               cattle-prometheus,
                               cattle-provisioning-capi-system,
                               cattle-resources-system,
                               cattle-sriov-system,
                               cattle-system,
                               cattle-ui-plugin-system,
                               cattle-windows-gmsa-system,
                               carbide-stigatron-system,
                               cert-manager,
                               compliance-operator-system,
                               fleet-default,
                               ingress-nginx,
                               istio-system,
                               kube-node-lease,
                               kube-public,
                               kube-system,
                               longhorn-system,
                               local-path-storage,
                               rancher-alerting-drivers,
                               security-scan,
                               tigera-operator]

    zypper:
      config: {download.use_deltarpm: true, reposdir: /etc/zypp/repos.d, servicesdir: /etc/zypp/services.d}
      repos:
        - {name: rancher-rke2-common-stable, id: rancher-rke2-common-stable, baseurl: 'https://foreman.randalllabs.com/pulp/content/Randall_Labs/Library/custom/rke2-slemicro/rancher-rke2-common-stable/', enabled: 1, gpgcheck: 0}
        - {name: rancher-rke2-1.35, id: rancher-rke2-1.35, baseurl: 'https://foreman.randalllabs.com/pulp/content/Randall_Labs/Library/custom/rke2-slemicro/rancher-rke2-1_35-stable/', enabled: 1, gpgcheck: 0}

    runcmd:
      - useradd -r -c "etcd user" -s /sbin/nologin -M etcd
      - echo "cloud-user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-cloud-init-users
      - echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml" >> /root/.bashrc
      - echo 'export PATH="/var/lib/rancher/rke2/bin:/usr/local/bin:$PATH"' >> /root/.bashrc
      - hostnamectl set-hostname `hostname -s`.${var.cluster_domain}
      - curl -o /etc/pki/trust/anchors/foreman.crt http://foreman.randalllabs.com/pub/katello-server-ca.crt
      - curl -o /etc/pki/trust/anchors/adca.cer http://192.168.80.7/adca.cer
      - update-ca-certificates
      - transactional-update pkg install -f -y rke2-server
      - echo "tls-san:" >> /etc/rancher/rke2/config.yaml
      - echo "- `hostname -f`" >> /etc/rancher/rke2/config.yaml
      - echo "- ${var.lb_ip}" >> /etc/rancher/rke2/config.yaml
      - echo "- ${var.rancher_fqdn}" >> /etc/rancher/rke2/config.yaml
      - cp -f /usr/share/rke2/rke2-cis-sysctl.conf /etc/sysctl.d/60-rke2-cis.conf
      - systemctl daemon-reload
      - systemctl enable firstboot.service --now
    users:
    - name: cloud-user
      ssh_authorized_keys:
       - ${data.harvester_ssh_key.default.public_key}
    EOF
}
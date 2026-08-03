resource "harvester_cloudinit_secret" "cloud-config-rke2-ctlplane" {
  name = "cloud-config-rke2-ctlplane"
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

      - path: /etc/rancher/rke2/config.yaml
        permissions: '644'
        content: | 
          server: https://${var.lb_ip}:9345
          token: ${var.join_token}
          ingress-controller: traefik
          system-default-registry: "${var.system_default_registry}"
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
    runcmd:
      - useradd -r -c "etcd user" -s /sbin/nologin -M etcd
      - echo "cloud-user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-cloud-init-users
      - echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml" >> /root/.bashrc
      - echo 'export PATH="/var/lib/rancher/rke2/bin:/usr/local/bin:$PATH"' >> /root/.bashrc
      - dnf -y rancher-selinux `echo rke2-server-${var.rke2_version} | sed -e "s/+/~/" | sed -e "s/server-v/server-/"`*
      - hostnamectl set-hostname `hostname -s`.${var.cluster_domain}
      - echo "tls-san:" >> /etc/rancher/rke2/config.yaml
      - echo "- `hostname -f`" >> /etc/rancher/rke2/config.yaml
      - echo "- ${var.lb_ip}" >> /etc/rancher/rke2/config.yaml
      - systemctl enable iscsid --now
      - cp -f /usr/share/rke2/rke2-cis-sysctl.conf /etc/sysctl.d/60-rke2-cis.conf
      - echo -e "fs.inotify.max_user_instances=8192\nfs.inotify.max_user_watches=524288\nfs.filemax=10000" > /etc/sysctl.d/61-fs-max.conf
      - systemctl restart fapolicyd 
      - systemctl restart systemd-sysctl
      - systemctl enable rke2-server --now
    users:
    - name: cloud-user
      ssh_authorized_keys:
       - ${data.harvester_ssh_key.default.public_key}
    EOF
}
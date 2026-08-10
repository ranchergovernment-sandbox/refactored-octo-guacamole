resource "harvester_cloudinit_secret" "cloud-config-rke2-agent" {
  name = "cloud-config-rke2-agent"
  namespace = "management"
  user_data = <<-EOF
    #cloud-config
    chpasswd:
      expire: false
    ssh_pwauth: true
    runcmd:
      - useradd -r -c "etcd user" -s /sbin/nologin -M etcd
      - echo "cloud-user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-cloud-init-users
      - hostnamectl set-hostname `hostname -s`.${var.cluster_domain}
      - curl -o /etc/pki/trust/anchors/foreman.crt http://foreman.randalllabs.com/pub/katello-server-ca.crt
      - curl -o /etc/pki/trust/anchors/adca.cer http://192.168.80.7/adca.cer
      - curl -o /etc/pki/trust/anchors/mlm.crt http://mlm.randalllabs.com/pub/RHN-ORG-TRUSTED-SSL-CERT
      - update-ca-certificates
    users:
    - name: cloud-user
      ssh_authorized_keys:
       - ${data.harvester_ssh_key.default.public_key}
    zypper:
      config: {download.use_deltarpm: true, reposdir: /etc/zypp/repos.d, servicesdir: /etc/zypp/services.d}
      repos:
        - {name: rancher-rke2-common-stable, id: rancher-rke2-common-stable, baseurl: 'https://foreman.randalllabs.com/pulp/content/Randall_Labs/Library/custom/rke2-microos/Rancher_RKE2_Common_stable_/', enabled: 1, gpgcheck: 0}
        - {name: rancher-rke2-1.34, id: rancher-rke2-1.34, baseurl: 'https://foreman.randalllabs.com/pulp/content/Randall_Labs/Library/custom/rke2-microos/Rancher_RKE2_1_35_stable_/', enabled: 1, gpgcheck: 0}
    EOF
}


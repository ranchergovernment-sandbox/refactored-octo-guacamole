# Install Hauler and sync content

- Pull and install the binary as root
    ```
    curl -sfL https://get.hauler.dev | bash
    ```

- Log in with Hauler to RGS registry
    ```bash
    hauler login registry.ranchercarbide.dev -u <username> -p <password>
    ```

- Download the required images and helm chart for Harbor
    ```bash
    hauler store sync --products apps-harbor=2.15.1 --platform linux/amd64 --product-registry registry.ranchercarbide.dev
    ```
    * Replace the harbor version, with the version you wish to use.  This was the latest at the time I created this document.

- Create bundle to copy to nodes
    ```bash
    hauler store save --containerd --platform linux/amd64
    ```
    This will create a file called `haul.tar.zst` rename that file to `harbor.tar.zst` so it can be differentiated from other hauler bundles.
    ```bash
    mv haul.tar.zst harbor.tar.zst
    ```
- SCP the bundle over to each of your Harvester nodes
    ```bash
    scp -O harbor.tar.zst rancher@192.168.85.11:
    scp -O harbor.tar.zst rancher@192.168.85.12:
    scp -O harbor.tar.zst rancher@192.168.85.13:
    ```

- As root on each Harvester node copy the bundle into the containerd cache
    ```bash
    mv harbor.tar.zst /var/lib/rancher/rke2/agent/images/
    ```

- Back on the bastion host, list contents of the store and extract the harbor helm chart from the harbor store
    ```bash
    hauler store list
    hauler store extract hauler/harbor:1.19.1
    ```
    * The version will be listed in your `hauler store list` command

- Create a `values.yaml` file from the helm chart
    ```bash
    helm show values harbor-1.19.1.tgz > values.yaml
    ```
- At the top of the values.yaml file you will need to specify the default registry.
    ```yaml
    global:
  # -- Global override for container image registry
  imageRegistry: ""
    ```
    * This should be `registry.ranchercarbide.dev`
- Edit `values.yaml` to reflect your requirements.  The following lines should be updated
    ```yaml
    ingress:
      hosts:
        core: core.harbor.domain
    ~~~~
    externalURL: https://core.harbor.domain
    ```
    * Change `core.harbor.domain` to be the FQDN used to reach the harbor instance.
    * You will need a DNS A or CNAME record that allows the above FQDN to resolve to the VIP  of the Harvester cluster

- Adjust the size of the volume claim to match the amount of space required for your registry.  Recommend 500Gi
    ```yaml
    persistence:
  enabled: true
  # Setting it to "keep" to avoid removing PVCs during a helm delete
  # operation. Leaving it empty will delete PVCs after the chart deleted
  # (this does not apply for PVCs that are created for internal database
  # and redis components, i.e. they are never deleted automatically)
  resourcePolicy: "keep"
  persistentVolumeClaim:
    registry:
      # Use the existing PVC which must be created manually before bound,
      # and specify the "subPath" if the PVC is shared with other components
      existingClaim: ""
      # Specify the "storageClass" used to provision the volume. Or the default
      # StorageClass will be used (the default).
      # Set it to "-" to disable dynamic provisioning
      storageClass: ""
      subPath: ""
      accessMode: ReadWriteOnce
      size: 5Gi
    ```
- It is highly suggested to start off using signed certificates, and having Harvester trust the CA that issued them.
    - In the Harvester UI, go to Advanced > Settings.  
    - The first thing you see will be additional-ca.  Click on the three dots in the upper right and select Edit Settings.
    - From there you can upload your CA file.
- We will not get into how to create a certificate as that is different based upon the CA used.
    - You will need both the certificate generated (preferably a wildcard cert that can be used for the entire cluster) and the private key.
- Since we are adding the secret for the TLS Certs before running the helm chart, we will need to create the namespace.
    ```bash
    kubectl create ns harbor
    ```
- Now create the TLS secret.
    ```bash
    kubectl create secret tls <name_of_secret> --cert=<path_to_certificate> --key=<path_to_key> -n harbor
    ```
- You can now update the `values.yaml` file to use the secret you just created for TLS certificate.
    ```yaml
    expose:
    # Set how to expose the service. Set the type as "ingress", "clusterIP", "nodePort", "loadBalancer" or "route"
    # and fill the information in the corresponding section
        type: ingress
        tls:
          # Enable TLS or not.
          # Delete the "ssl-redirect" annotations in "expose.ingress.annotations" when TLS is disabled and "expose.type" is "ingress"
          # Note: if the "expose.type" is "ingress" and TLS is disabled,
          # the port must be included in the command when pulling/pushing images.
          # Refer to https://github.com/goharbor/harbor/issues/5291 for details.
          enabled: true
          # The source of the tls certificate. Set as "auto", "secret"
          # or "none" and fill the information in the corresponding section
          # 1) auto: generate the tls certificate automatically
          # 2) secret: read the tls certificate from the specified secret.
          # The tls certificate can be generated manually or by cert manager
          # 3) none: configure no tls certificate for the ingress. If the default
          # tls certificate is configured in the ingress controller, choose this option
          certSource: auto
          auto:
            # The common name used to generate the certificate, it's necessary
            # when the type isn't "ingress"
            commonName: ""
          secret:
            # The name of secret which contains keys named:
            # "tls.crt" - the certificate
            # "tls.key" - the private key
            secretName: ""
    ```
    * Change the `certSource:` to secret, and put  the name of the secret you just created in the `secretName:` field

- You can now install harbor.
    ```bash
    helm install harbor -n harbor harbor-1.19.1.tgz -f values.yaml
    ```
    * if you did not create the namespace to upload certificates earlier, you will need to add the `--create-namespace` option to the above helm install command.

- Now that you have a Harbor instance running, you will need to log in and create a `project` for each item you are going to sync in.
- Run through the folders here to sync content from the Internet and then into your Harbor.
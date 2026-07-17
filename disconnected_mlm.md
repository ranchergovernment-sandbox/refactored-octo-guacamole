# MLM Server disconnected
- Install SUSE SLEM 6.1 on system
- Use NMCLI to configure network
- Set Hostname
    ```bash
    hostnamectl set-hostname <FQDN for your MLM>
    ```

- Add hostname to hosts file 
- Register system with RMT system
    ```bash
    curl -O http://<fqdn of rmt>/tools/rmt-client-setup
    curl -O http://<fqdn of rmt>rmt.crt
    sudo cp rmt.crt /etc/pki/trust/anchors/
    sudo update-ca-certificates
    transactional-update register --url https://<fqdn of rmt host>
    ```

- Reboot system
- Register the SUSE Manager 5 extension
    ```bash
    transactional-update register -p Multi-Linux-Manager-Server/5.1/x86_64
    ```
- Reboot system
- Update system
    ```bash
    transactional-update; reboot
    ```
- Install the required packages
    ```bash
    transactional-update pkg install mgradm* mgrctl* suse-multi-linux-manager-5.1-x86_64-server-*
    ```
- Reboot system
- Install SUSE Manager with mgradm
    ```bash
    mgradm install podman <fqdn for mlm server>
    ```
- Update storage to use second disk
    ```bash
    mgr-storage-server <second disk>
    ```
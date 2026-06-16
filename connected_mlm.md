# MLM Server connected
- Install SUSE SLEM 6.1 on system
- Use NMCLI to configure network
- Set Hostname
    ```bash
    hostnamectl set-hostname <FQDN for your MLM>
    ```

- Add hostname to hosts file 
- Register system with RGS
    ```bash
    transactional-update register --url https://rgscc.ranchergovernment.com --write-config -r <RGS REGCODE>
    ```

- Reboot system
- Register the SUSE Manager 5 extension
    ```bash
    transactional-update register -p Multi-Linux-Manager-Server/5.1/x86_64 -r <RGS REGCODE>
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
    mgradm install podman mlm.randalllabs.com
    ```
- Edit `/var/lib/containers/storage/volumes/etc-rhm/_data/rhn.conf` and add the following at the end of the file.
    ```bash
    scc_url = https://rgscc.ranchergovernment.com
    ```
- Restart the container
    ```bash
    podman restart $(podman ps | grep 'server:5' | awk '{print $1}')
    ```
- Update storage to use second disk
    ```bash
    mgr-storage-server <second disk>
    ```
- Pull up Web UI and login with password given during install
- Under Admin > Setup Wizard > Organization Credentials, add your username/password
- Under Admin > Setup Wizard > Products, select the products you want synched.
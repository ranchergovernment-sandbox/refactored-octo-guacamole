# RMT Server connected

- Install SUSE SLES 15 p7
- Use YAST to configure network
- Register system with RGS
    ```bash
    SUSEConnect --url https://rgscc.ranchergovernment.com --write-config -r $REGCODE
    ```
    *Use code for SLES*

- Refresh repos
    ```bash
    zypper ref
    ```

- Update system
    ```bash
    zypper up
    ```
- Reboot server after updates

- Install rmt
    ```bash
    zypper in rmt-server yast2-rmt nginx mariadb
    ```

- Configure rmt
    ```bash
    yast rmt
    ```
    *provide org credentials.  you will get an error, because it is trying to connect to scc.suse.com that is expected, finish setup*  
- Edit the `/etc/rmt.conf` file to add host: https://rgscc.ranchergovernment.com/connect to the scc section
- Restart rmt and sync
    ```bash
    systemctl restart rmt-server ; rmt-cli sync
    rmt-cli products list --all
    ```
- Enable repos  
    ```bash
    3022 Multi-Linux-Manager-Server/5.1/x86_64 
    3099 Multi-Linux-Manager-Server-SLE/5.1/x86_64
    2774 SL-Micro/6.1/x86_64
    ```
*The number for the repos MAY bed different on your system, but you will need to get the repo ID number for the above listed repos*  
    ```bash
    rmt-cli products enable 3022 3099 2774
    ```
- Mirror repos
    ```bash
    rmt-cli mirror
    ```
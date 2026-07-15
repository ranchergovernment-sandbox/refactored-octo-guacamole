# RMT Server disconnected

## Install SUSE SLES 15 p7

- Using the cursor keys select Installation from the SLES boot screen, and press enter. 

![sles boot screen](images/sles15-boot-screen.png)

- The installation process will begin.  The system will be probed for hardware, and SLES will attempt to update the installer.  Since this is a disconnected system, it will eventually time out.

- You will then be given a screen to select the product to install.  Select SUSE Linux Enterprise Server 15 SP7 and select Next.

![sles-product-selection](images/sles15-product-selection.png)

- Read through the license agreement and if you agree, select the checkbox next to `I Agree to the License Terms.` and then select next.

![sles-eula](images/sles15-eula.png)

- On the Registration page, select `Skip Registration` and you will be prompted with a pop-up notifying you registration is required for updates.  Select OK, then Next.

![sles-registration](images/sles15-registration.png)

- The system will be probed and repositories enabled.  You will come to an Extension and Module Selection page that you can leave as is and just click Next.

![sles-modules](images/sles15-modules.png)

- On the Add-On Product page just click Next.

![sles-add-on](images/sles-15-add-on.png)

- On the System Role page, make sure `Text Mode` is selected and click Next.

![sles-system-role](images/sles15-sytem-role.png)

- SLES will suggest partitioning for your system.  Since this system will not be a permanent part of the environment, I generally don't spend much time here.  Click on `show details` in the middle and ensure that the `/var` subvolume has at least 40G of space.  If you are not satisfied with the layout, you can use either Guided Setup or Expert Partitioner if desired.  When complete click Next.

![sles-partition-layout](images/sles15-partition-layout.png)

- Select the appropriate time-zone for your server.

![sles-timezone](images/sles15-timezone.png)

- Create a new user and provide a password.  Select the checkbox for `Use this password for system administrator` and select Next.

![sles-user](images/sles15-user.png)

- On the Installation Settings page click on `Software` in blue at the top of the page.

![sles-installation](images/sles15-installation-settings.png)

- On the Software Selection page click on the Details button on the bottom left.

![sles-software](images/sles15-software-selection.png)

- Click on the Search tab at the top of the page and in the search field put `rmt`.  Select the checkbox for rmt-server, and rmt-server-config and yast2-rmt will automatically be selected.  Then click on Accept.

![sles-rmt](images/sles15-select-rmt.png)

- A dialog will pop up letting you know that additional software will be installed as it is dependencies of the rmt-server.  Click on Continue.

![sles-automatic-changes](images/sles15-automatic-changes.png)

- This will bring you back to the Installation Settings page with the updated information for software added, click on `Network Configuration` in blue near the bottom of the page, you may have to scroll to see it.

![sles-install-updated](images/sles15-install-settings-updated.png)

- In Network Settings select Edit at the bottom left of the page.

![sles-network](images/sles15-network-settings.png)

- Select the radio button for Statically Assigned IP Address, and insert your IP Address, Subnet Mask and Hostname, then click on Next.

![sles-ip](images/sles15-ip.png)

- Click on the Hostname/DNS tab and type in your fully qualified domain name (fqdn) for this host.  Change Set Hostname via DHCP to no, and put in your DNS servers and Domain name in appropriate locations.  Click Next and the installer will update your configuration.

![sles-dns](images/sles15-dns.png)

- This brings you back to the `Installation Settings` page.  We now need to go back into Network Configuration to set our default route.

- In the Routing tab, select the check box to Enable IPv4 Forwarding, and click on the Add button at the bottom.

![sles-route](images/sles15-enable-route.png)

- In the pop-up ensure that Default Route is checked and place your gateway IP in the Gateway field, and select the NIC from the Device drop-down and select ok.

![sles-gateway](images/sles15-gateway.png)

- Back on the Network Settings page click Next.  This will update your Network Settings and take you back to the Installation Settings Page.  You can now Click on Install.

- A confirmation dialog will pop up, click on Install.

![sles-confim](images/sles15-confirm-install.png)


- Configure rmt
    ```bash
    yast rmt
    ```
    - Do not place anything in `Organization Username or Password`
    - Remove the X from `Forward systems to SCC
    - Tab down and select [Skip]

    ![rmt-org](images/rmt-org.png)

- The Skip SCC registration confirmation dialog comes up, tab and select [Ignore and continue]
![skip-reg](images/rmt-skip-reg.png)

- Hit enter in the dialog that states `Configuration written successfully`

- Leave the database credentials username as rmt, and provide your own password, then tab down and select [Next].

![rmt-db-pass](images/rmt-db-pass.png)

- Provide and confirm a password for root within the MariaDB database, then tab and select [OK].

![rmt-db-root-pass](images/rmt-db-root-pass.png)

- Hit enter in the dialog that states `Configuration written successfully`
- In the SSL Certificate Generation page tab and select [Next]

- In the CA private key popup, provide and confirm a password for the CA's private key that will be generated, then tab and select [OK].

![rmt-ca-key](images/rmt-ca-pass.png)

- Select Open Ports... to have the firewall allow traffic into RMT, then tab and select [Next].

![rmt-firewall](images/rmt-firewall.png)

- You will then get a confirmation that the service has been started, tab and select [Next].

![rmt-service](images/rmt-service.png)

- You will now get a confirmation page, tab and select [Finish]

![rmt-finish](images/rmt-confirm.png)

- RMT is now ready to import the content exported from the connected RMT.
# Installation of the RGS products for a disconnected environment
Documentation for RGS products can be found at https://docs.ranchercarbide.dev.  

Clone this git repository to a Linux host that has Internet connectivity.  There are some scripts here that will aide in getting the required content into your environment.  

Before you can do an installation in a disconnected environment you will need to synchronize in some content.  I generally break this down into two different processes.  

First we need to synchronize the content required to deploy Harbor.  After we have that content we can then synchronize all the required content that will be stored in the Harbor Registry Server in the Disconnected environment.

## Harvester
You will need to download the Harvester installation ISO and transfer it to the disconnected environment.  
The Harvester Installation ISO can be found [here](https://portal.staging.ranchercarbide.dev/product/harvester)  
It is recommended that you download the latest `govt` version.  

[Install Harvester](harvester.md)  
[Install Harbor in Harvester disconnected](harbor.md)  

Now that Harbor is up and running in your Harvester cluster, it is time to get some content in to it.  

If you have cloned this repo to your connected Linux host, you can use it to download the RGS content, and any additional software you may want to deploy in the RGS suite.

The first thing you will want to do is to edit the [versions](versions) file with the versions of the software you wish to bring into your environment.  If you are not certain which versions are available, you can look in the [Carbide Registry](https://portal.staging.ranchercarbide.dev/).  You should have been provided credentials to login to this RGS provided registry.  This is the same site for downloading the Harvester ISO linked above.  

Once you have updated the `versions` file, you should be ready to run the `sync.sh` script inside the [0_connected_download_carbide](0_connected_download_carbide/) directory.  

 Look in the [1_connected_download_appco](1_connected_download_appco/) directory and edit the `sync.sh` script.  Comment out any of these applications that you do not wish to sync at this time.  Once you have the script updated with the applications you want, you can then run the script just like done before.

 The [2_connected_download_thirdparty](2_connected_download_thirdparty/) directory has various applications not provided by RGS that you may want to sync into your environment.  You may want to grab the kube-vip from there.  This allows RKE2/Rancher to have an internal VIP similar to how Harvester does it, and not rely on an external load balancer.
 
Once the connected syncs are completed, you will want to tar up the entire directory where you cloned the git repo, and transfer it to your disconnected environment.

Untar the archive you created in the last step.

Go into the [3_disconnected_upload](3_disconnected_upload/) directory.  

Update the `env.sh` file with the FQDN of your Harbor instance.

If you synced any third party content, uncomment the third for loop in the `upload.sh` script.  You may now run the script to synchronize the content into your disconnected Harbor instance.





### Extra SUSE products
[Connected RMT Server](connected_rmt.md)  
[Connected MLM Server](connected_mlm.md)  
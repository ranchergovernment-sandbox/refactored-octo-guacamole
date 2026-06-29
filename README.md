# Installation of the RGS products for a disconnected environment
Documentation for RGS products can be found at https://docs.ranchercarbide.dev.  
Clone this git repository to a Linux host that has Internet connectivity.  There are some scripts here that will aide in getting the required content into your environment.  

Before you can do an installation in a disconnected environment you will need to synchronize in some content.  I generally break this down into two different processes.  

First we need to synchronize the content required to deploy Harbor.  After we have that content we can then synchronize all the required content that will be stored in the Harbor Registry Server in the Disconnected environment.

## Harvester
You will need to download the Harvester installation ISO and transfer it to the disconnected environment.  
The Harvester Installation ISO can be found [here](https://portal.staging.ranchercarbide.dev/product/harvester)  
It is recommended that you download the latest `govt` version that is not `experimental`.  

[Install Harvester](harvester.md)  
[Install Harbor in Harvester disconnected](harbor.md)  
Now that Harbor is up and running in your Harvester cluster, it is time to get some content in to it.  
Inside the [0_connected_download_carbide](0_connected_download_carbide/) and [1_connected_download_appco](1_connected_download_appco/) directories you will find a `sync.sh` script that you can run to sync that content into your connected system, and the [3_disconnected_upload](3_disconnected_upload/) folder has an `upload.sh` script that will synchronize the content into your disconnected Harbor instance.





### Extra SUSE products
[Connected RMT Server](connected_rmt.md)  
[Connected MLM Server](connected_mlm.md)  
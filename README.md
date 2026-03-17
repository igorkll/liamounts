# liamounts
the system of automatic mounting of removable media for linux  
this module exists to replace udisks2 in my distribution  
the main distinguishing feature is that all external devices with a linux file system are mounted ignoring access rights  
this is necessary because my distribution does not have root access, and this solution will allow you to freely use removable media from ext4 without worrying about access rights  

## paths
* /automounts - the directory with the endpoints of the mount. It is necessary to display it in the explorer
* /realmounts - the directory for the actual mount points. file systems with unix access rights are mounted here in order to make bindfs from realmounts to automounts later. users do not have access to realmounts

## dependencies
* udev
* at
* bindfs

## conflicts
* udisks2

# Network
Networking scripts

CreateFolderByADUser.ps1 : Create personal shared folder
-
Simply execute the script on AD server and enter the path to create user folder when asked. Just share the parent folder.

mapdrive_by_group.vbs : Map network drive to user by group
-
Login script that can by put in a GPO to map network drive according to user group. You only need to change the group name and the shared folder path.

ipchanger.sh : Change IP address on interface
-
Synthax: ./ipchanger.sh -> *interface* -> 192.168.0.100/24 OR 192.168.0.100/24/192.168.0.1 (ip/prefix/gateway).

sudo growpart /dev/nvme0n1 4
sudo lvextend -L +20G /dev/RootVG/rootVol
sudo lvextend -L +10G /dev/RootVG/homeVol

#increasing root volume size
sudo xfs_growfs /
#increasing home dir storage size
sudo xfs_growfs /home
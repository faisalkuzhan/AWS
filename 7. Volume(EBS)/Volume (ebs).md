
# Hands-on EC2-04 : Extending and Partitioning EBS Volumes

git

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- understand what is the difference between root volume and EBS Volume.

- list volumes to show current status of primary (root) and additional volumes

- demonstrate their knowledge on how to create EBS volume.

- create mounting point on EC2 instances.

- partition volume on EC2 instances.

- resize the volume or partitions on the new EBS volumes.

- understand how to auto-mount EBS volumes and partitions after reboots.

## Outline
- 

- Part 1 - Extend EBS Volume without Partitioning

- Part 2 - Extend EBS Volume with Partitioning

- Part 3 - Extend the Root Volume

- Part 4 - Auto-mount EBS Volumes and Partitions on Reboot

![EBS Volumes](./ebs_backed_instance.png)

# PART 1 - EXTEND EBS VOLUME WITHOUT PARTITIONING

- launch an instance from aws console in "us-east-1a" AZ.
- check volumes which volumes attached to instance. 
- only root volume should be listed
```
lsblk
```
## Section 0 - Create new Volume 

- create a new volume in the same AZ "us-east-1" with the instance from AWS console "5 GB" for this demo.
- attach the new volume from aws console, then list block storages again.
- root volume and secondary volume should be listed
```
lsblk
```
## Section 1 - Mounting Volume

- check if the attached volume is already formatted or not and has data on it.
```
sudo file -s /dev/xvdf
```
# sonucunda data cikiyorsa bu yer bir yere bagli degildir.

- if not formatted, format the new volume
```
sudo mkfs -t ext4 /dev/xvdf
```
# bu sekilde dosyaya format atiyoruz. cunku format olmadan islem yapamiyoruz.
- check the format of the volume again after formatting
```
sudo file -s /dev/xvdf
```
# artik formatlama olduama dosyayi yine goremiyoruz. cunku mounting islemini tamamlamadik.
- create a mounting point path for new volume (volume-1)
```
sudo mkdir /mnt/mp1
```
# mount yapmak icin bir tane dosya olusturuyoruz.

- mount the new volume to the mounting point path
```
sudo mount /dev/xvdf /mnt/mp1/
```
# /dev/xvdf ile /mnt/mp1/ dosyalarini birbirine bagla.

- check if the attached volume is mounted to the mounting point path
```
lsblk
```
- show the available space, on the mounting point path
```
df -h
```
- check if there is data on it or not.
```
ls  /mnt/mp1/
```
- if there is no data on it, create a new file to show persistence in later steps

```
cd /mnt/mp1
sudo touch hello.txt
ls
```
## Section 2: Enlarge the new volume (volume-1) in AWS console and modify from terminal

- modify the new volume in aws console, and enlarge capacity from 5GB to 6GB .
- check if the attached volume is showing the new capacity 
```
# burada consoldan modify ile volume 5 den 6 gb cikariyoruz. ls yaptigimizda bu gozukecek fakat df -h da gozukmeyecek.
lsblk
```
- show the real capacity used currently at mounting path, old capacity should be shown.
```
df -h
```
- resize the file system on the new volume to cover all available space.
```
sudo resize2fs /dev/xvdf
# bu komut ile 5 gb in formatini ekledigimiz 1 gb da uygulamis olduk. 
```
- show the real capacity used currently at mounting path, new capacity should reflect the modified volume size.
```
df -h
```
- show that the data still persists on the newly enlarged volume.
```
ls /mnt/mp1/
```
# bu komut ile belirtilen adreste var olan dosyalarin gitmedigini de goruyoruz.

## Section 3: Rebooting Instance

show that mounting point path will be gone when instance rebooted 
```
sudo reboot now
# bu komuttan sonra public ve private adres degismez. 
```
- show the new volume is still attached, but not mounted
```
lsblk
```
- check if the attached volume is "already formatted" or not and has data on it.
```
sudo file -s /dev/xvdf
# dosyalama sisteminin olup olmadigini gorebiliyoruz.
```
- mount the new volume to the mounting point path
```
sudo mount /dev/xvdf /mnt/mp1/
# reboot yapmis oldugumuzdan baglanti koptu. bu komut ile tekrar bagliyoruz.    
```
- show the used and available capacity is same as the disk size.
```
lsblk
df -h
```
- if there is data on it, check if the data still persists.
```
ls  /mnt/mp1/
```

# PART 2 - EXTEND EBS VOLUME WITH PARTITIONING

- https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/recognize-expanded-volume-linux.html

- https://www.tecmint.com/fdisk-commands-to-manage-linux-disk-partitions/

- list volumes to show current status, primary (root) and secondary volumes should be listed
```
lsblk
```
- show the used and available capacities related with volumes
```
df -h
```
## Section 0: Create new volume

- create tertiary volume (5 GB for this demo) in the same AZ "us-east-1" with the instance on aws console
- attach the new volume from aws console, then list volumes again.
-  primary (root), secondary and tertiary volumes should be listed
```
lsblk
```
- show the used and available capacities related with volumes
```
df -h
```
- show the current partitions... use "fdisk -l /dev/xvda" for specific partition
```
sudo fdisk -l
```

## Section 1: Make partition-1

- check all available fdisk commands and using "m".

```
sudo fdisk /dev/xvdg
# bu komut ile olusturdugumuz ve ec2 bagladigimiz volume partition lara ayiriiyoruz.

 n -> add new partition (with 1G size)
 p -> primary
 Partition number: 1
 First sector: default - use Enter to select default
 Last sector: +2G
  
 
 n -> add new partition (with rest of the size-1G)
 p -> primary
 Partition number: 2
 First sector: default - use Enter to select default
 Last sector: default - use Enter to select default
 w -> write partition table
 
 ```
- format the new partitions
```
Bu komutlar ile mount yapabilmek icin format atiyoruz.
sudo mkfs -t ext4 /dev/xvdg1
sudo mkfs -t ext4 /dev/xvdg2
```
- create a mounting point path for new volume
```
sudo mkdir /mnt/mp2
sudo mkdir /mnt/mp3
# Bu komutlar ile mount yapabilmek icin klasor olusturuyoruz.
```
- mount the new volume to the mounting point path
```
sudo mount /dev/xvdg1 /mnt/mp2/
sudo mount /dev/xvdg2 /mnt/mp3/
```
- list volumes to show current status, all volumes and partitions should be listed
```
lsblk
```
- show the used and available capacities related with volumes and partitions
```
df -h
```

- if there is no data on it, create a new file to show persistence in later steps
```
sudo touch /mnt/mp3/helloguys.txt
ls  /mnt/mp3/
```
## Section 3: Enlarge capacity 

- modify the new (3rd) volume in aws console, and enlarge capacity 1 GB more (from 5GB to 6GB for this demo).
- check if the attached volume is showing the new capacity
```
lsblk
```
- show the real capacity used currently at mounting path, old capacity should be shown.
```
df -h
```
- extend the partition 2 and occupy all newly available space.  Warning for space !!!!!!
```
sudo growpart /dev/xvdg 2
# bu sekilde artirilmis volume uzatiyorum.
```
- ​show the real capacity used currently at mounting path, updated capacity should be shown.
```
lsblk
```
- resize and extend the FILE System.
```
sudo resize2fs /dev/xvdg2
# bu sekilde formatliyorum.
```
- show the newly created file to show persistence

```
ls  /mnt/mp3/
```

# PART 3 - EXTEND ROOT VOLUME

- Check file system of the root volume's partition.
```
sudo file -s /dev/xvda1
```

- Go to Volumes, select instance's root volume and modify it (increase capacity 8 GB >> 12 GB).
# burada root volume 12 gb cikariyoruz.

- List block devices (lsblk) and file system disk space usage (df) of the instance again.

- Root volume should be listed as increased but partition and file system should be listed same as before.
```
lsblk
df -h
```
- Extend partition 1 on the modified volume and occupy all newly avaiable space.
```
sudo growpart /dev/xvda 1
# uzattigimiz volume ekliyoruz.
```
- Resize the xfs file system on the extended partition to cover all available space.

```
sudo xfs_growfs /dev/xvda1
# uzattigimiz volume formatliyoruz..
```
- List block devices (lsblk) and file system disk space usage (df) of the instance again.
- Partition and file system should be extended.
```
lsblk
df -h
```
# PART 4 - AUTOMOUNT EBS VOLUMES AND PARTITIONS ON REBOOT

# normalde reboot ettigimizde root volume haric diger bagladigimiz dosyalar gidiyor. 
# tekrar baglamamiz gerekiyor. ama asagidakileri yaparsak buna gerek kalmaz. reboot yapsakta bagladigimiz dosyalari gorebiliyriz.

- reboot and show that configuration is gone
```
sudo reboot now
```
- back up the /etc/fstab file.
```
sudo cp /etc/fstab /etc/fstab.bak
# burada kendimizi saglama almak icin baska bir yere de kopyaliyoruz.
```
- open /etc/fstab file and 

```
sudo nano /etc/fstab 
```
- add the following info to the existing.(UUID's can also be used)
```
 /dev/xvdf       mnt/mp1   ext4    defaults,nofail        0       0
 /dev/xvdg1      mnt/mp2   ext4  defaults,nofail        0       0
 /dev/xvdg2      mnt/mp3   ext4  defaults,nofail        0       0
```
- CTRL+X and Y to save

- reboot and show that configuration exists (NOTE)
```
sudo reboot now
```
- list volumes to show current status, all volumes and partitions should be listed
```
lsblk
```
- show the used and available capacities related with volumes and partitions
```
df -h
```
- if there is data on it, check if the data still persists.
```
ls  /mnt/mp1/
ls  /mnt/mp3/
```

# NOTE: You can use "sudo mount -a" to mount volumes and partitions after editing fstab file without rebooting.
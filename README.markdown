# Puppet vKick Module #

#### Define KVM virtual machines and the guest's OS setup
- Combine KVM definition and Kickstart OS setup in a single module declaration.
- Create virtual machines in a centralized way with full OS setup from your Puppet master.
- Simply define which Linux flavor to install by pointing to the right HTTP mirror.
- Can be faster than bootstrapping an image, especially if you want an up to date OS.  

-------

#### Examples 
You'll find 3 main themes to define a virtual machine: network, partitioning and packages.  
The simplest definition will only need network settings and will create a CentOS 6.5 VM with 2 vcpu, 2GB of RAM and a 40GB disk image:
```
 vkick::guest { 'instance1.domain.com':
       root_intial_passwd => "5hould8eReplaced"
       ipaddress   => "173.255.197.131",
       subnetmask  => "255.255.255.0",
       broadcast   => "173.255.197.255",
       gateway     => "173.255.197.254",
 }
```

To define a bigger Fedora 20 VM with a LAMP stack (where P is for Python):
```
 vkick::guest { 'instance2.domain.com':
 	   vcpu		   => 4,
 	   ram		   => 16384,
 	   disk_size   => 120,
 	   os_variant  => 'fedora16',
 	   http_mirror => 'http://fedora.mirrors.ovh.net/linux/releases/20/Fedora/x86_64/os/',
 	   http_updates => 'http://fr2.rpmfind.net/linux/fedora/linux/updates/20/x86_64/',
 	   timezone	   => 'Europe/London',
 	   packages    => ['httpd', 'mariadb-server', 'MySQL-python', 'python']
       root_intial_passwd => "5hould8eReplaced"
       ipaddress   => "173.255.197.131",
       subnetmask  => "255.255.255.0",
       broadcast   => "173.255.197.255",
       gateway     => "173.255.197.254",
 }
```

Adapt HTTP mirrors to a server nearby and serving the right version for your CPU architecture.
The CPU architecture is inherited from, the host's CPU, there for only the number of vcpu/thread is left to assign.
Without specifying a partition scheme, the follow settings will be used:
- An ext4 /boot partition of 512MB.
- 2GB of swap.
- 10GB for an ext4 / partition as part of a LVM volume.
- 4GB for an ext4 /home partition as part of a LVM volume.
- All remaining space of the specified disk size will be used for a /var ext4 partition as part of a LVM volume.

#### Requirements
- A working network bridge defined on the host.
- A CPU with support for virtualization via KVM.
- An access to the internet from the guest's IP or a local HTTP mirror.
- A version of python-virtinst equal or superior to 0.500.4-1 to support injecting Kickstart definition without local ISO or floppy installation image. 

#### Known Limitations
- Only works for guest OS supporting Kickstart files such as RedHat, CentOS, Fedora and Ubuntu (would need custom Kickstart template to, among other things, use apt-get rather than yum).
- Requires a guest setup with static IP, either public or private if local mirror available.
- Doesn't create other user accounts than root on a guest.
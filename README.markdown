# Puppet vKick Module #

#### Define KVM virtual machines and the guest's OS setup
- Combine KVM definition and Kickstart OS setup in a single module declaration.
- Create multiple virtual machines on a single Puppet node.
- Can be faster than bootstrapping an image, especially if you want an up to date OS. 

-------

#### Example 
You'll find 3 main themes to define a virtual machine: network, partitioning and packages.
The simplest definition will only need network settings and will create a basic VM with 2 vcpu; 2GB of RAM and a 40GB disk image.
```
 vkick::guest { 'instance1.domain.com':
       root_intial_passwd => "5hould8eReplaced"
       ipaddress   => "173.255.197.131",
       subnetmask  => "255.255.255.0",
       broadcast   => "173.255.197.255",
       gateway     => "173.255.197.254",
       nameserver  => "208.67.222.222",
 }
```

#### Requirements
- A working network bridge device defined on the host.
- An access to the internet for the guest's IP or a local HTTP mirror.
- A recent version of libvirt/qemu (as shipped with EL 6.x) to support injecting Kickstart definition without local ISO installation image. 

#### Known Limitations
- Only works on Linux distributions supporting Kickstart files such as RedHat, CentOS, Fedora and Ubuntu (not tested).
- Requires a guest setup with static IP, ethier public or private if local mirror available.
- Doesn't create other user accounts than root on a guest.
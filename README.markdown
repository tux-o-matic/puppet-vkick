[![Build Status](https://travis-ci.org/tux-o-matic/puppet-vkick.svg?branch=master)](https://travis-ci.org/tux-o-matic/puppet-vkick)
# Puppet vKick Module

## Define KVM virtual machines and the guest's OS setup
- Combine KVM definition and Kickstart OS setup in a single module declaration.
- Create virtual machines in a centralized way with full OS setup from your Puppet master.
- Simply define which Linux flavor to install by pointing to the right HTTP mirror.
- Can be faster than bootstrapping an image, especially if you want an up to date OS.  

## Examples
```shell
node 'host1.domain.com' {
  include vkick::host
}
```
You can modify the libvirt image path or bridge device name by assigning those parameters to the vkick:host class in your node classification.

You'll find 3 main groups to define a virtual machine: network, partitioning and packages. The simplest definition will only need network settings and will create a CentOS 6.5 VM with 2 vcpu, 2GB of RAM and a 40GB disk image:
```shell
node 'host1.domain.com' {
  include vkick::host

  vkick::guest { 'instance1.domain.com':
       root_intial_passwd => '$5$random_salt$cZtPYSe77B7/NJHzUSHr1AEOMnQQpIbLWPmIboI2nG3',
       ipaddress          => "173.255.197.131",
       subnetmask         => "255.255.255.0",
       broadcast          => "173.255.197.255",
       gateway            => "173.255.197.254"
 }
}
```

To define a bigger Fedora 20 VM with a LAMP stack, download and install PuppetLabs repo meta then finally install the Puppet client:
```shell
node 'host1.domain.com' {
  include vkick::host
  
  vkick::guest { 'instance2.domain.com':
   	vcpu		              => 4,
   	ram		                => 16384,
   	disk_size             => 120,
   	os_variant            => 'fedora16',
   	http_mirror           => 'http://fedora.mirrors.ovh.net/linux/releases/20/Fedora/x86_64/os/',
   	http_updates          => 'http://fr2.rpmfind.net/linux/fedora/linux/updates/20/x86_64/',
   	timezone	            => 'Europe/London',
   	packages              => ['httpd', 'mariadb-server', 'MySQL-python']
   	packages_to_download  => ['http://yum.puppetlabs.com/puppetlabs-release-pc1-fedora-20.noarch.rpm'],
   	packages_post_install => ['puppet-agent'],
    pass_algorithm        => 'sha512',
    root_intial_passwd    => '$6$random_salt$TNrwyNX0/aJaE8Ee/.dchDiGLxINLMiRTX.DX0SpGzYXE9MDgCq8qYsEBqBe5pPUKtPTUxoTXJyIgdsWQ1Csp0',
    ipaddress             => "173.255.197.131",
    subnetmask            => "255.255.255.0",
    broadcast             => "173.255.197.255",
    gateway               => "173.255.197.254"
  }
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


### Password encryption:
To improve security, especially when Puppet configuration is hosted in a repository off-premise, the root password injected via Kickstart with this module should be encrypted. To obtain the hashed version of your password, you can use these commands:
* sha256:
```shell
python -c 'import crypt; print crypt.crypt("5hould8eReplaced", "$5$random_salt")'
```
* sha512:
```shell
python -c 'import crypt; print crypt.crypt("5hould8eReplaced", "$6$random_salt")'
```

## Hiera
If you want to define VMs via Hiera, add the following in you site.pp:
```shell
$vkick_guests = hiera_hash('vkick_guests', {})
create_resources('::vkick::guest', $vkick_guests)
```
Then in your Hiera configuration for a node:
```yaml
vkick_guests:
  'instance1.domain.com':
    root_intial_passwd: '$5$random_salt$cZtPYSe77B7/NJHzUSHr1AEOMnQQpIbLWPmIboI2nG3'
    ipaddress: '173.255.197.131'
    subnetmask: '255.255.255.0'
    broadcast: '173.255.197.255'
    gateway: '173.255.197.254'
    packages:
      - 'httpd'
      - 'mariadb-server'
      - 'MySQL-python'
```

## Requirements
- A working network bridge defined on the host.
- A CPU with support for virtualization via KVM.
- An access to the internet from the guest's IP or a local HTTP mirror.
- A version of python-virtinst equal or superior to 0.500.4-1 to support injecting Kickstart definition without local ISO or floppy installation image. 

## Known Limitations
- Only works for guest OS supporting Kickstart files such as RedHat, CentOS, Fedora and Ubuntu (would need custom Kickstart template to, among other things, use apt-get rather than yum).
- Requires a guest setup with static IP, either public or private if a gateway or local mirror is available.
- Doesn't create other user accounts than root on a guest.

## For Feedbacks and Suggestions: Twitter @tux_o_matic

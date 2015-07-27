#    Puppet module to create virtual machines defined by code via Kickstart files.
#    Copyright (C) 2014  Benjamin Merot (ben@busyasabee.org)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
# Sample Usage:
# vkick::guest { 'instance1.domain.com':
#       root_intial_passwd => "5hould8eReplaced"
#       ipaddress   => "173.255.197.131",
#       subnetmask  => "255.255.255.0",
#       broadcast   => "173.255.197.255",
#       gateway     => "173.255.197.254",
#       nameserver  => "208.67.222.222",
# }
#
# Parameters:
# template: Specify a custom Kickstart template added to the templates folder with the .cfg.erb extension, by default uses the shipped kickstart.cfg.rb template.
# nameserver: A DNS server, by default one of OpenDNS servers.
# bridge_device: If not defined, will use value defined in vkick::host which by default is br0
# mac: The virtual mac address of the guest, some ISP or network gears expect this to be pre defined or vendor generated.
# format: The format of the disk image, qcow2 or raw.
# disk_size: The disk image size in GB.
# os_type: The OS type of the guest, only some linux distros support Kickstart configuration.
# os_variant: The variant, ushc as rhel6 or fedora.
# http_mirror: The HTTP mirror where the Linux boot kernel and packages are available.
# http_updates: The optional HTTP mirror, if specified the OS and packages will be updated during the installation process.
# packages: Extra packages to install from the mirror
# packages_to_download: List of URLs from where extra RPM packages should be downloaded and installed from HTTP servers
# packages_post_install: List of RPM packages to install in the last phase of the OS installation, such as RPM available from a repository defined from a source in $packages_to_download. 

define vkick::guest (
  $hostname           = $name,
  $template           = 'kickstart',
  $vcpu               = 2,
  $ram                = 2048,
  $pass_algorithm     = 'sha256',
  $root_intial_passwd = '',
  $ipaddress          = '',
  $subnetmask         = '',
  $broadcast          = '',
  $gateway            = '',
  $nameserver         = '208.67.222.222',
  $bridge_device      = '',
  $mac                = '52:54:00:12:34:57',
  $format             = 'qcow2',
  $disk_size          =  40,
  $os_type            = 'linux',
  $os_variant         = 'rhel6',
  $http_mirror        = 'http://mirror.fysik.dtu.dk/linux/centos/6.5/os/x86_64/',
  $http_updates       = 'http://mirror.fysik.dtu.dk/linux/centos/6.5/updates/x86_64/',
  $timezone           = 'Europe/Paris',
  $locale             = 'en_US',
  $keyboard           = 'us',
  $parition_rules     = [
    'part /boot --fstype=ext4 --size=512',
    'part swap --size=2048',
    'part pv.00 --size=1 --grow',
    'volgroup vg_main pv.00',
    'logvol / --fstype=ext4 --name=lv_root --vgname=vg_main --size=10240',
    'logvol /home --fstype=ext4 --name=lv_home --vgname=vg_main --size=4096',
    'logvol /var --fstype=ext4 --name=lv_var --vgname=vg_main --size=1 --grow'],
  $packages           = ['telnet', 'vim-enhanced', 'wget'],
  $packages_to_download = [],
  $packages_post_install = []) {

  $supported_algorithms = [
    'sha256',
    'sha512',
  ]

  validate_re($pass_algorithm, $supported_algorithms)
    
  include vkick::host

  if $bridge_device == '' {
    $bridge = $vkick::host::bridge_device
  } else {
    $bridge = $bridge_device
  }

  $cmd = "virt-install --name=${hostname} --ram=${ram} --cpu=host --vcpus=${vcpu} --network bridge=${bridge},mac=${mac} --disk path=${vkick::host::image_path}/${hostname}.${format},size=${disk_size},bus=virtio,format=${format} --os-type=${os_type} --os-variant=${os_variant} --nographics --hvm --location=${http_mirror} --initrd-inject=${vkick::host::image_path}/${hostname}.cfg --extra-args=\"ks=file:/${hostname}.cfg console=tty0 console=ttyS0,115200\" --force --noautoconsole"

  file { "${vkick::host::image_path}/${hostname}.cfg":
    content => template("vkick/${template}.cfg.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  exec { "create_vm":
    command => "${cmd}",
    timeout  => 0,
    creates => "${vkick::host::image_path}/${hostname}.${format}",
  }

}

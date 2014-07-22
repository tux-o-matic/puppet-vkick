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
# This module can be used without the need to overwrite the default values of the parameters of the vkick::host class for many cases.
#

class vkick::host ($image_path = '/var/lib/libvirt/images/', $bridge_device = 'br0') {
  $packages = ["kvm", "qemu-kvm", "python-virtinst", "libvirt-python", "libguestfs-tools", "virt-manager", "bridge-utils"]

  package { "libvirt": ensure => present, }

  package { $packages:
    ensure  => present,
    require => Package["libvirt"]
  }

  service { "libvirtd":
    ensure  => "running",
    require => Package["libvirt"]
  }
  
  #if $is_virtual == 'true'{
    #throw error
  #}

}
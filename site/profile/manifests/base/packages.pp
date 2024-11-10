class profile::base::packages (
  Array[String] $ensured_package_list,
  Array[String] $purged_package_list,
) {
  case $virtual {
    'kvm':  {
      $qemu_guest_agent = 'qemu-guest-agent'
      if ! ($qemu_guest_agent in $ensured_package_list) {
         $package_list = $ensured_package_list << $qemu_guest_agent
      }
      service { $qemu_guest_agent:
        ensure => 'running',
        enable => true,
        require => Package[$qemu_guest_agent],
      }
    }
    'vmware':  {
      $open_vm_tools = 'open-vm-tools'
      if ! ($open_vm_tools in $ensured_package_list) {
         $package_list = $ensured_package_list << $open_vm_tools
      }
    }
    default:  {
      # no virtualization, do nothing
    }
  }

  profile::base::ensure_and_purge_packages {'base_packages':
    ensured_package_list => $package_list,
    purged_package_list => $purged_package_list,
  }
}

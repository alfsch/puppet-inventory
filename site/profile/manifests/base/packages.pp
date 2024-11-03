class profile::base::packages (
  Array[String] $ensured_package_list,
  Array[String] $purged_package_list,
) {
  # install the packages that are required by the base profile
  package { $ensured_package_list:
    ensure => latest,
  }

  # only purge packages that are not required by the ensured_package_list
  $purge_packages = difference($purged_package_list, $ensured_package_list)
  # purge the packages that are not required by the base profile
  package { $purge_packages:
    ensure => purged,
  }

  if ($virtual == "kvm") {
    package { [
            'qemu-guest-agent',
            ]:
     ensure => latest,
    }
    service { 'qemu-guest-agent':
      ensure => 'running',
      enable => true,
      require => Package['qemu-guest-agent'],
    }
  }
  if ($virtual == "vmware") {
    package { [
            'open-vm-tools',
            ]:
     ensure => latest,
    }
  }
}

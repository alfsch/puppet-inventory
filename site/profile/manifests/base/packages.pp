class profile::base::packages (
  Array[String] $ensured_package_list,
  Array[String] $purged_package_list,
) {
  # install the packages that are required by the base profile
  package { $ensured_package_list:
    ensure => latest,
  }

  # purge the packages that are not required by the base profile
  package { $purged_package_list:
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

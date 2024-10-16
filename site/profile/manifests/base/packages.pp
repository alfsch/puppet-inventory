class profile::base::packages {
  package { [
            'avahi-utils',
            'byobu',
            'bzip2',
            'ca-certificates',
            'cifs-utils',
            'curl',
            'fdisk',
            'gdisk',
            'gnupg-agent',
            'iptraf-ng',
            'jq',
            'keyutils',
            'locate',
            'members',
            'net-tools',
            'nfs-common',
            'openssl',
            'pwgen',
            'seccomp',
            'smbclient',
            'sudo',
            'tcpdump',
            'unzip',
            'vim',
            'wget',
            ]:
    ensure => latest,
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

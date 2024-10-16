class profile::base::apt {
  apt::pin { 'disable-distros-puppet-agent':
    explanation     => 'Disable puppet-agent package from distributors repository',
    originator      => $facts['os']['distro']['id'],
    packages        => [
                         'puppet-agent',
                       ],
    priority        => -1000,
  }

  # workaround for puppet-agent module not supporting apt keyring
  # to get rid of apt key deprecated warning
  apt::source { 'puppet-release':
    location => 'https://apt.puppetlabs.com/',
    repos    => 'puppet7 puppet8',
    key      => {
      name   => 'puppetlabs-keyring.gpg',
      source => 'https://apt.puppetlabs.com/keyring.gpg',
    },
  }

  class { 'apt':
    update      => {
      frequency => 'daily',
    },
  }
}

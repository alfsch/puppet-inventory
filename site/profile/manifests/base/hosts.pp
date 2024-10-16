class profile::base::hosts {
  # host entries needed for all nodes
  host { $facts['fqdn']:
    ensure       => 'present',
    ip           => '127.0.1.1',
    host_aliases => $facts['hostname'],
    target       => '/etc/hosts',
  }
}

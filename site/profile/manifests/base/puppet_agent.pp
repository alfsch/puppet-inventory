class profile::base::puppet_agent {
  class {'::puppet_agent':
    package_version         => 'present',
    collection              => 'puppet8',
    config => [
                {
                  ensure    => present,
                  section   => agent,
                  setting   => number_of_facts_soft_limit,
                  value     => '5120',
      },
    ],
    manage_repo             => false,
  }
}

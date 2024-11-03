class profile::base {
  include profile::base::apt
  include profile::base::hosts
  include profile::base::packages
  include profile::base::puppet_agent
  include profile::base::unattended_upgrades
}

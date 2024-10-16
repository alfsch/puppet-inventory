class profile::base {
  include profile::base::hosts
  include profile::base::apt
  include profile::base::packages
  include profile::base::hosts
}

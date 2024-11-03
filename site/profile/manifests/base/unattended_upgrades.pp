class profile::base::unattended_upgrades(
  Array[String] $blacklist,
  Array[String] $extra_origins,
  Integer $max,
  Integer $min,
  Boolean $reboot,
  Boolean $reboot_withusers,
  String $reboot_time,
) {
  class { 'unattended_upgrades':
    age => {
       'max' => $max,
       'min' => $min,
    },
    auto => {
       'reboot' => $reboot,
       'reboot_withusers' => $reboot_withusers,
       'reboot_time' => $reboot_time,
    },
    blacklist => $blacklist,
    extra_origins => $extra_origins,
    remove_unused_kernel => true,
  }
}

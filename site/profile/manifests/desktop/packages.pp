class profile::desktop::packages (
  Array[String] $ensured_package_list,
  Array[String] $purged_package_list,
) {
  $base_ensured_package_list = lookup('profile::base::packages::ensured_package_list', {value_type => Array[String], default_value => []})
  $base_purged_package_list = lookup('profile::base::packages::purged_package_list', {value_type => Array[String], default_value => []})
  profile::base::ensure_and_purge_packages {'desktop_packages':
    ensured_package_list => difference($ensured_package_list, $base_ensured_package_list),
    purged_package_list  => difference($purged_package_list, $base_purged_package_list),
  }
}

define profile::base::ensure_and_purge_packages (
  Array[String] $ensured_package_list = [],
  Array[String] $purged_package_list = [],
) {
  # install the packages that are required by $ensured_package_list
  package { $ensured_package_list.unique:
    ensure => latest,
  }

  # only purge packages that are not required by the $ensured_package_list
  $purge_packages = difference($purged_package_list, $ensured_package_list)
  # purge the packages that are not required by the base profile
  package { $purge_packages.unique:
    ensure => purged,
  }
}

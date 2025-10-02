# == Class: gnocchi
#
# Full description of class gnocchi here.
#
# === Parameters
#
# [*package_ensure*]
#   (optional) The state of gnocchi packages
#   Defaults to 'present'
#
# [*coordination_url*]
#   (optional) The url to use for distributed group membership coordination.
#   Defaults to $facts['os_service_default'].
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the gnocchi config.
#   Defaults to false.
#
# [*manage_backend_package*]
#   (Optional) Whether to install the backend package.
#   Defaults to true.
#
# [*backend_package_ensure*]
#   (Optional) ensure state for backend package.
#   Defaults to 'present'
#
class gnocchi (
  Stdlib::Ensure::Package $package_ensure         = 'present',
  $coordination_url                               = $facts['os_service_default'],
  Boolean $purge_config                           = false,
  Boolean $manage_backend_package                 = true,
  Stdlib::Ensure::Package $backend_package_ensure = present,
) inherits gnocchi::params {
  include gnocchi::deps

  package { 'gnocchi':
    ensure => $package_ensure,
    name   => $gnocchi::params::common_package_name,
    tag    => ['openstack', 'gnocchi-package'],
  }

  resources { 'gnocchi_config':
    purge => $purge_config,
  }

  oslo::coordination { 'gnocchi_config':
    backend_url            => $coordination_url,
    manage_backend_package => $manage_backend_package,
    package_ensure         => $backend_package_ensure,
    manage_config          => false,
  }
  gnocchi_config {
    'DEFAULT/coordination_url' : value => $coordination_url, secret => true;
  }

  # all coordination settings should be applied and all packages should be
  # installed before service startup
  Oslo::Coordination['gnocchi_config'] -> Anchor['gnocchi::service::begin']
}

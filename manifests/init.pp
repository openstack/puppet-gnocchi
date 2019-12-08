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
# [*database_connection*]
#   (optional) Connection url for the gnocchi database.
#   Defaults to undef.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the gnocchi config.
#   Defaults to false.
#
class gnocchi (
  $package_ensure      = 'present',
  $database_connection = undef,
  $purge_config        = false,
) inherits gnocchi::params {

  include gnocchi::deps
  include gnocchi::db

  package { 'gnocchi':
    ensure => $package_ensure,
    name   => $::gnocchi::params::common_package_name,
    tag    => ['openstack', 'gnocchi-package'],
  }

  resources { 'gnocchi_config':
    purge => $purge_config,
  }

}

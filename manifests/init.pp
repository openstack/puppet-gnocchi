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
#   Defaults to $::os_service_default.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the gnocchi config.
#   Defaults to false.
#
class gnocchi (
  $package_ensure   = 'present',
  $coordination_url = $::os_service_default,
  $purge_config     = false,
) inherits gnocchi::params {

  include gnocchi::deps

  package { 'gnocchi':
    ensure => $package_ensure,
    name   => $::gnocchi::params::common_package_name,
    tag    => ['openstack', 'gnocchi-package'],
  }

  resources { 'gnocchi_config':
    purge => $purge_config,
  }

  gnocchi_config {
    'DEFAULT/coordination_url' : value => $coordination_url;
  }

  if ($coordination_url =~ /^redis/ ) {
    ensure_packages('python-redis', {
      ensure => $package_ensure,
      name   => $::gnocchi::params::redis_package_name,
      tag    => 'openstack',
    })
  }
}

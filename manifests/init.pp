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
# [*log_dir*]
#   (optional) Directory where logs should be stored.
#   If set to boolean false or the $::os_service_default, it will not log to
#   any directory.
#   Defaults to undef
#
# [*debug*]
#   (optional) Set log output to debug output.
#   Defaults to undef
#
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults to undef
#
# [*use_stderr*]
#   (optional) Use stderr for logging
#   Defaults to undef
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines.
#   Defaults to undef
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
# DEPRECATED PARAMETERS
#
# [*ensure_package*]
#   (optional) The state of gnocchi packages
#   Defaults to undef
#
class gnocchi (
  $package_ensure      = 'present',
  $debug               = undef,
  $use_syslog          = undef,
  $use_stderr          = undef,
  $log_dir             = undef,
  $log_facility        = undef,
  $database_connection = undef,
  $purge_config        = false,
  # DEPRECATED PARAMETERS
  $ensure_package      = undef,
) inherits gnocchi::params {

  include ::gnocchi::deps
  include ::gnocchi::db
  include ::gnocchi::logging

  if $ensure_package {
    warning("gnocchi::ensure_package is deprecated and will be removed in \
the future release. Please use gnocchi::package_ensure instead.")
    $package_ensure_real = $ensure_package
  } else {
    $package_ensure_real = $package_ensure
  }

  package { 'gnocchi':
    ensure => $package_ensure_real,
    name   => $::gnocchi::params::common_package_name,
    tag    => ['openstack', 'gnocchi-package'],
  }

  resources { 'gnocchi_config':
    purge => $purge_config,
  }

}

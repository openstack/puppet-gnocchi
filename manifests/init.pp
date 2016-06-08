# == Class: gnocchi
#
# Full description of class gnocchi here.
#
# === Parameters
#
# [*ensure_package*]
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
# [*verbose*]
#   (optional) Deprecated. Set log output to verbose output.
#   Defaults to undef
#
class gnocchi (
  $ensure_package      = 'present',
  $debug               = undef,
  $use_syslog          = undef,
  $use_stderr          = undef,
  $log_dir             = undef,
  $log_facility        = undef,
  $database_connection = undef,
  $purge_config        = false,
  # Deprecated
  $verbose             = undef,
) inherits gnocchi::params {


  if $verbose {
    warning('verbose is deprecated, has no effect and will be removed after Newton cycle.')
  }

  include ::gnocchi::db
  include ::gnocchi::logging

  package { 'gnocchi':
    ensure => $ensure_package,
    name   => $::gnocchi::params::common_package_name,
    tag    => ['openstack', 'gnocchi-package'],
  }

  resources { 'gnocchi_config':
    purge => $purge_config,
  }

}

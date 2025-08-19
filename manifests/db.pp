# == Class: gnocchi::db
#
#  Configure the Gnocchi database
#
# === Parameters
#
# [*database_db_max_retries*]
#   (optional) Maximum retries in case of connection error or deadlock error
#   before error is raised. Set to -1 to specify an infinite retry count.
#   Defaults to $facts['os_service_default']
#
# [*database_connection*]
#   Url used to connect to database.
#   (Optional) Defaults to 'sqlite:////var/lib/gnocchi/gnocchi.sqlite'.
#
# [*slave_connection*]
#   (optional) Connection url to connect to aodh slave database (read-only).
#   Defaults to $facts['os_service_default'].
#
# [*database_connection_recycle_time*]
#   Timeout when db connections should be reaped.
#   (Optional) Defaults to $facts['os_service_default'].
#
# [*database_max_pool_size*]
#   Maximum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to $facts['os_service_default'].
#
# [*database_max_retries*]
#   Maximum number of database connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   (Optional) Defaults to $facts['os_service_default'].
#
# [*database_retry_interval*]
#   Interval between retries of opening a database connection.
#   (Optional) Defaults to $facts['os_service_default'].
#
# [*database_max_overflow*]
#   If set, use this value for max_overflow with sqlalchemy.
#   (Optional) Defaults to $facts['os_service_default'].
#
# [*database_pool_timeout*]
#   (Optional) If set, use this value for pool_timeout with SQLAlchemy.
#   Defaults to $facts['os_service_default']
#
# [*mysql_enable_ndb*]
#   (Optional) If True, transparently enables support for handling MySQL
#   Cluster (NDB).
#   Defaults to $facts['os_service_default']
#
# [*package_ensure*]
#   (optional) The state of gnocchi packages
#   Defaults to 'present'
#
class gnocchi::db (
  $database_db_max_retries          = $facts['os_service_default'],
  Oslo::DBconn $database_connection = 'sqlite:////var/lib/gnocchi/gnocchi.sqlite',
  $slave_connection                 = $facts['os_service_default'],
  $database_connection_recycle_time = $facts['os_service_default'],
  $database_max_pool_size           = $facts['os_service_default'],
  $database_max_retries             = $facts['os_service_default'],
  $database_retry_interval          = $facts['os_service_default'],
  $database_max_overflow            = $facts['os_service_default'],
  $database_pool_timeout            = $facts['os_service_default'],
  $mysql_enable_ndb                 = $facts['os_service_default'],
  $package_ensure                   = 'present',
) inherits gnocchi::params {
  include gnocchi::deps

  oslo::db { 'gnocchi_config':
    db_max_retries          => $database_db_max_retries,
    slave_connection        => $slave_connection,
    connection_recycle_time => $database_connection_recycle_time,
    max_pool_size           => $database_max_pool_size,
    max_retries             => $database_max_retries,
    retry_interval          => $database_retry_interval,
    max_overflow            => $database_max_overflow,
    pool_timeout            => $database_pool_timeout,
    mysql_enable_ndb        => $mysql_enable_ndb,
    manage_backend_package  => false,
    manage_config           => true,
  }

  # NOTE(tkajinam): Gnocchi does not use [database] connection but use
  #                 [indexer] url to obtain database connection url. So
  #                 database_connection is used separately only to determine
  #                 the required dependencies we should install.
  oslo::db { 'gnocchi_config_connection':
    config                 => 'gnocchi_config',
    connection             => $database_connection,
    backend_package_ensure => $package_ensure,
    manage_backend_package => true,
    manage_config          => false,
  }

  gnocchi_config {
    'indexer/url': value => $database_connection, secret => true;
  }

  # all db settings should be applied and all packages should be installed
  # before dbsync starts
  Oslo::Db['gnocchi_config'] -> Anchor['gnocchi::dbsync::begin']
  Oslo::Db['gnocchi_config_connection'] -> Anchor['gnocchi::dbsync::begin']
}

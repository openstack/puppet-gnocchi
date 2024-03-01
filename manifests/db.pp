# == Class: gnocchi::db
#
#  Configure the Gnocchi database
#
# === Parameters
#
# [*database_connection*]
#   Url used to connect to database.
#   (Optional) Defaults to 'sqlite:////var/lib/gnocchi/gnocchi.sqlite'.
#
# [*package_ensure*]
#   (optional) The state of gnocchi packages
#   Defaults to 'present'
#
class gnocchi::db (
  Oslo::DBconn $database_connection = 'sqlite:////var/lib/gnocchi/gnocchi.sqlite',
  $package_ensure                   = 'present',
) inherits gnocchi::params {

  include gnocchi::deps

  oslo::db { 'gnocchi_config':
    connection             => $database_connection,
    backend_package_ensure => $package_ensure,
    manage_config          => false,
  }

  gnocchi_config {
    'indexer/url': value => $database_connection, secret => true;
  }

  # all db settings should be applied and all packages should be installed
  # before dbsync starts
  Oslo::Db['gnocchi_config'] -> Anchor['gnocchi::dbsync::begin']
}

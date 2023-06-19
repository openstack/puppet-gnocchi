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

  if $database_connection {
    case $database_connection {
      /^mysql(\+pymysql)?:\/\//: {
        require mysql::bindings
        require mysql::bindings::python
        if $database_connection =~ /^mysql\+pymysql/ {
          $backend_package = $::gnocchi::params::pymysql_package_name
        } else {
          $backend_package = false
        }
      }
      /^postgresql:\/\//: {
        $backend_package = false
        require postgresql::lib::python
      }
      /^sqlite:\/\//: {
        $backend_package = $::gnocchi::params::sqlite_package_name
      }
      default: {
        fail('Unsupported backend configured')
      }
    }

    if $backend_package and !defined(Package[$backend_package]) {
      package {'gnocchi-backend-package':
        ensure => present,
        name   => $backend_package,
        tag    => 'openstack',
      }
    }

    gnocchi_config {
      'indexer/url': value => $database_connection, secret => true;
    }

    if $::gnocchi::params::indexer_package_name != undef {
      package { 'gnocchi-indexer-sqlalchemy':
        ensure => $package_ensure,
        name   => $::gnocchi::params::indexer_package_name,
        tag    => ['openstack', 'gnocchi-package'],
      }
    }
  }

}

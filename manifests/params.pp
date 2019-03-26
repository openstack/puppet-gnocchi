# ==Class: gnocchi::params
#
# Parameters for puppet-gnocchi
#
class gnocchi::params {
  include openstacklib::defaults

  $client_package_name        = 'python3-gnocchiclient'
  $rados_package_name         = 'python3-rados'
  $common_package_name        = 'gnocchi-common'
  $api_package_name           = 'gnocchi-api'
  $api_service_name           = 'gnocchi-api'
  $metricd_package_name       = 'gnocchi-metricd'
  $metricd_service_name       = 'gnocchi-metricd'
  $statsd_package_name        = 'gnocchi-statsd'
  $statsd_service_name        = 'gnocchi-statsd'
  $group                      = 'gnocchi'
  $gnocchi_wsgi_script_source = '/usr/bin/gnocchi-api'
  $boto3_package_name         = 'python3-boto3'

  case $::osfamily {
    'RedHat': {
      $sqlite_package_name        = undef
      $indexer_package_name       = 'openstack-gnocchi-indexer-sqlalchemy'
      $gnocchi_wsgi_script_path   = '/var/www/cgi-bin/gnocchi'
      $pymysql_package_name       = undef
    }
    'Debian': {
      $sqlite_package_name        = 'python-pysqlite2'
      $indexer_package_name       = undef
      $gnocchi_wsgi_script_path   = '/usr/lib/cgi-bin/gnocchi'
      $pymysql_package_name       = 'python3-pymysql'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem")
    }

  } # Case $::osfamily
}

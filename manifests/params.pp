# ==Class: gnocchi::params
#
# Parameters for puppet-gnocchi
#
class gnocchi::params {
  include ::openstacklib::defaults

  $client_package_name  = 'python-gnocchiclient'
  $rados_package_name   = 'python-rados'
  $common_package_name  = 'gnocchi-common'
  $api_service_name     = 'gnocchi-api'
  $metricd_package_name = 'gnocchi-metricd'
  $metricd_service_name = 'gnocchi-metricd'
  $statsd_package_name  = 'gnocchi-statsd'
  $statsd_service_name  = 'gnocchi-statsd'
  $group                = 'gnocchi'

  case $::osfamily {
    'RedHat': {
      $api_package_name           = 'gnocchi-api'
      $sqlite_package_name        = undef
      $indexer_package_name       = 'openstack-gnocchi-indexer-sqlalchemy'
      $gnocchi_wsgi_script_path   = '/var/www/cgi-bin/gnocchi'
      $gnocchi_wsgi_script_source = '/usr/bin/gnocchi-api'
      $pymysql_package_name       = undef
      $cradox_package_name        = 'python2-cradox'
      $redis_package_name         = 'python-redis'
    }
    'Debian': {
      if $::operatingsystem == 'Ubuntu' {
        $api_package_name           = 'python-gnocchi'
        $gnocchi_wsgi_script_source = '/usr/bin/python2-gnocchi-api'
      } else {
        $api_package_name           = 'gnocchi-api'
        $gnocchi_wsgi_script_source = '/usr/share/gnocchi-common/app.wsgi'
      }

      $sqlite_package_name        = 'python-pysqlite2'
      $gnocchi_wsgi_script_path   = '/usr/lib/cgi-bin/gnocchi'
      $pymysql_package_name       = 'python-pymysql'
      $redis_package_name         = 'python-redis'
      $cradox_package_name        = undef
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem")
    }

  } # Case $::osfamily
}

# ==Class: gnocchi::params
#
# Parameters for puppet-gnocchi
#
class gnocchi::params {
  include ::openstacklib::defaults

  $client_package_name = 'python-gnocchiclient'
  $rados_package_name  = 'python-rados'

  case $::osfamily {
    'RedHat': {
      $sqlite_package_name        = undef
      $common_package_name        = 'openstack-gnocchi-common'
      $api_package_name           = 'openstack-gnocchi-api'
      $api_service_name           = 'openstack-gnocchi-api'
      $indexer_package_name       = 'openstack-gnocchi-indexer-sqlalchemy'
      $metricd_package_name       = 'openstack-gnocchi-metricd'
      $metricd_service_name       = 'openstack-gnocchi-metricd'
      $statsd_package_name        = 'openstack-gnocchi-statsd'
      $statsd_service_name        = 'openstack-gnocchi-statsd'
      $gnocchi_wsgi_script_path   = '/var/www/cgi-bin/gnocchi'
      $gnocchi_wsgi_script_source = '/usr/lib/python2.7/site-packages/gnocchi/rest/app.wsgi'
      $pymysql_package_name       = undef
      $cradox_package_name        = 'python2-cradox'
      $redis_package_name         = 'python-redis'
    }
    'Debian': {
      $sqlite_package_name        = 'python-pysqlite2'
      $common_package_name        = 'gnocchi-common'
      $api_package_name           = 'gnocchi-api'
      $api_service_name           = 'gnocchi-api'
      $indexer_package_name       = 'gnocchi-indexer-sqlalchemy'
      $metricd_package_name       = 'gnocchi-metricd'
      $metricd_service_name       = 'gnocchi-metricd'
      $statsd_package_name        = 'gnocchi-statsd'
      $statsd_service_name        = 'gnocchi-statsd'
      $gnocchi_wsgi_script_path   = '/usr/lib/cgi-bin/gnocchi'
      $gnocchi_wsgi_script_source = '/usr/share/gnocchi-common/app.wsgi'
      $pymysql_package_name       = 'python-pymysql'
      $redis_package_name         = 'python-redis'
      $cradox_package_name        = undef
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem")
    }

  } # Case $::osfamily
}

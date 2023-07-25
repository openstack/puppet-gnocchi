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
  $user                       = 'gnocchi'
  $group                      = 'gnocchi'
  $gnocchi_wsgi_script_source = '/usr/bin/gnocchi-api'
  $boto3_package_name         = 'python3-boto3'

  case $facts['os']['family'] {
    'RedHat': {
      $gnocchi_wsgi_script_path = '/var/www/cgi-bin/gnocchi'
    }
    'Debian': {
      $gnocchi_wsgi_script_path = '/usr/lib/cgi-bin/gnocchi'
    }
    default: {
      fail("Unsupported osfamily: ${facts['os']['family']}")
    }

  } # Case $facts['os']['family']
}

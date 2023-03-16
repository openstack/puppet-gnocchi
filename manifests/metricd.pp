# Installs & configure the gnocchi metricd service
#
# == Parameters
#
# [*enabled*]
#   (optional) Should the service be enabled.
#   Defaults to true
#
# [*package_ensure*]
#   (optional) ensure state for package.
#   Defaults to 'present'
#
# [*workers*]
#   (optional) the number of workers.
#   Defaults to $facts['os_workers']
#
# [*metric_processing_delay*]
#   (optional) Delay between processing metrics
#   Defaults to $facts['os_service_default'].
#
# [*greedy*]
#   (optional) Allow to bypass metric_processing_delay if metricd is noticed
#   that messages are ready to be processed.
#   Defaults to $facts['os_service_default'].
#
# [*metric_reporting_delay*]
#   (optional) How many seconds to wait between metric ingestion reporting.
#   Defaults to $facts['os_service_default'].
#
# [*metric_cleanup_delay*]
#   (optional) How many seconds to wait between cleaning of expired data.
#   Defaults to $facts['os_service_default'].
#
# [*processing_replicas*]
#   (optional) Number of workers tht share a task.
#   Defaults to $facts['os_service_default'].
#
# [*manage_service*]
#   (optional) Whether the service should be managed by Puppet.
#   Defaults to true.
#
class gnocchi::metricd (
  $manage_service          = true,
  $enabled                 = true,
  $workers                 = $facts['os_workers'],
  $metric_processing_delay = $facts['os_service_default'],
  $greedy                  = $facts['os_service_default'],
  $metric_reporting_delay  = $facts['os_service_default'],
  $metric_cleanup_delay    = $facts['os_service_default'],
  $processing_replicas     = $facts['os_service_default'],
  $package_ensure          = 'present',
) inherits gnocchi::params {

  include gnocchi::deps

  validate_legacy(Boolean, 'validate_bool', $manage_service)
  validate_legacy(Boolean, 'validate_bool', $enabled)

  gnocchi_config {
    'metricd/workers':                 value => $workers;
    'metricd/metric_processing_delay': value => $metric_processing_delay;
    'metricd/greedy':                  value => $greedy;
    'metricd/metric_reporting_delay':  value => $metric_reporting_delay;
    'metricd/metric_cleanup_delay':    value => $metric_cleanup_delay;
    'metricd/processing_replicas':     value => $processing_replicas;
  }

  package { 'gnocchi-metricd':
    ensure => $package_ensure,
    name   => $::gnocchi::params::metricd_package_name,
    tag    => ['openstack', 'gnocchi-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    service { 'gnocchi-metricd':
      ensure     => $service_ensure,
      name       => $::gnocchi::params::metricd_service_name,
      enable     => $enabled,
      hasstatus  => true,
      hasrestart => true,
      tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
    }
  }
}

# Installs & configure the gnocchi api service
#
# == Parameters
#
# [*enabled*]
#   (optional) Should the service be enabled.
#   Defaults to true
#
# [*manage_service*]
#   (optional) Whether the service should be managed by Puppet.
#   Defaults to true.
#
# [*max_limit*]
#   (optional) The maximum number of items returned in a
#   single response from a collection resource.
#   Defaults to $facts['os_service_default']
#
# [*package_ensure*]
#   (optional) ensure state for package.
#   Defaults to 'present'
#
# [*service_name*]
#   (optional) Name of the service that will be providing the
#   server functionality of gnocchi-api.
#   If the value is 'httpd', this means gnocchi-api will be a web
#   service, and you must use another class to configure that
#   web service. For example, use class { 'gnocchi::wsgi::apache'...}
#   to make gnocchi-api be a web app using apache mod_wsgi.
#   Defaults to '$gnocchi::params::api_service_name'
#
# [*sync_db*]
#   (optional) Run gnocchi-upgrade db sync on api nodes after installing the package.
#   Defaults to false
#
# [*auth_strategy*]
#   (optional) Configure gnocchi authentication.
#   Can be set to noauth and keystone.
#   Defaults to 'keystone'.
#
# [*paste_config*]
#   (Optional) Path to API paste configuration.
#   Defaults to $facts['os_service_default'].
#
# [*operation_timeout*]
#   (Optional) Number of seconds before timeout when attempting to do some
#   operations.
#   Defaults to $facts['os_service_default'].
#
# [*enable_proxy_headers_parsing*]
#   (Optional) Enable paste middleware to handle SSL requests through
#   HTTPProxyToWSGI middleware.
#   Defaults to $facts['os_service_default'].
#
# [*max_request_body_size*]
#   (Optional) Set max request body size
#   Defaults to $facts['os_service_default'].
#
class gnocchi::api (
  Boolean $manage_service       = true,
  Boolean $enabled              = true,
  $package_ensure               = 'present',
  $max_limit                    = $facts['os_service_default'],
  $service_name                 = $gnocchi::params::api_service_name,
  Boolean $sync_db              = false,
  $auth_strategy                = 'keystone',
  $paste_config                 = $facts['os_service_default'],
  $operation_timeout            = $facts['os_service_default'],
  $enable_proxy_headers_parsing = $facts['os_service_default'],
  $max_request_body_size        = $facts['os_service_default'],
) inherits gnocchi::params {

  include gnocchi::deps
  include gnocchi::policy

  package { 'gnocchi-api':
    ensure => $package_ensure,
    name   => $gnocchi::params::api_package_name,
    tag    => ['openstack', 'gnocchi-package'],
  }

  if $sync_db {
    include gnocchi::db::sync
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    if $service_name == $gnocchi::params::api_service_name {
      service { 'gnocchi-api':
        ensure     => $service_ensure,
        name       => $gnocchi::params::api_service_name,
        enable     => $enabled,
        hasstatus  => true,
        hasrestart => true,
        tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
      }

      # On any paste-api.ini config change, we must rstart Gnocchi API.
      Gnocchi_api_paste_ini<||> ~> Service['gnocchi-api']
      # On any uwsgi config change, we must restart Gnocchi API.
      Gnocchi_api_uwsgi_config<||> ~> Service['gnocchi-api']

    } elsif $service_name == 'httpd' {
      service { 'gnocchi-api':
        ensure => 'stopped',
        name   => $gnocchi::params::api_service_name,
        enable => false,
        tag    => ['gnocchi-service', 'gnocchi-db-sync-service'],
      }
      Service <| title == 'httpd' |> { tag +> 'gnocchi-service' }

      # we need to make sure gnocchi-api/eventlet is stopped before trying to start apache
      Service['gnocchi-api'] -> Service[$service_name]

      # On any paste-api.ini config change, we must rstart Gnocchi API.
      Gnocchi_api_paste_ini<||> ~> Service[$service_name]

    } else {
      fail("Invalid service_name. Either gnocchi/openstack-gnocchi-api for running as a \
standalone service, or httpd for being run by a httpd server")
    }
  }

  gnocchi_config {
    'api/max_limit':                    value => $max_limit;
    'api/auth_mode':                    value => $auth_strategy;
    'api/paste_config':                 value => $paste_config;
    'api/operation_timeout':            value => $operation_timeout;
    'api/enable_proxy_headers_parsing': value => $enable_proxy_headers_parsing;
  }

  oslo::middleware { 'gnocchi_config':
    max_request_body_size => $max_request_body_size,
  }

  if $auth_strategy == 'keystone' {
    include gnocchi::keystone::authtoken
  }
}

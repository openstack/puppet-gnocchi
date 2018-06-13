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
#   Defaults to 1000
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
#   Defaults to '$::gnocchi::params::api_service_name'
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
# [*enable_proxy_headers_parsing*]
#   (Optional) Enable paste middleware to handle SSL requests through
#   HTTPProxyToWSGI middleware.
#   Defaults to $::os_service_default.
#
# [*middlewares*]
#   (optional) Middlewares to use.
#   Defaults to $::os_service_default
#
class gnocchi::api (
  $manage_service               = true,
  $enabled                      = true,
  $package_ensure               = 'present',
  $max_limit                    = 1000,
  $service_name                 = $::gnocchi::params::api_service_name,
  $sync_db                      = false,
  $auth_strategy                = 'keystone',
  $enable_proxy_headers_parsing = $::os_service_default,
  $middlewares                  = $::os_service_default,
) inherits gnocchi::params {

  include ::gnocchi::deps
  include ::gnocchi::policy

  package { 'gnocchi-api':
    ensure => $package_ensure,
    name   => $::gnocchi::params::api_package_name,
    tag    => ['openstack', 'gnocchi-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  if $sync_db {
    include ::gnocchi::db::sync
  }

  if $service_name == $::gnocchi::params::api_service_name {
    service { 'gnocchi-api':
      ensure     => $service_ensure,
      name       => $::gnocchi::params::api_service_name,
      enable     => $enabled,
      hasstatus  => true,
      hasrestart => true,
      tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
    }
  } elsif $service_name == 'httpd' {
    include ::apache::params

    service { 'gnocchi-api':
      ensure => 'stopped',
      name   => $::gnocchi::params::api_service_name,
      enable => false,
      tag    => ['gnocchi-service', 'gnocchi-db-sync-service'],
    }
    Service <| title == 'httpd' |> { tag +> 'gnocchi-service' }

    # we need to make sure gnocchi-api/eventlet is stopped before trying to start apache
    Service['gnocchi-api'] -> Service[$service_name]
  } else {
    fail("Invalid service_name. Either gnocchi/openstack-gnocchi-api for running as a \
standalone service, or httpd for being run by a httpd server")
  }

  gnocchi_config {
    'api/max_limit': value   => $max_limit;
    'api/auth_mode': value   => $auth_strategy;
    'api/middlewares': value => $middlewares;
  }

  oslo::middleware { 'gnocchi_config':
    enable_proxy_headers_parsing => $enable_proxy_headers_parsing,
  }

  if $auth_strategy == 'keystone' {
    include ::gnocchi::keystone::authtoken
  }
}

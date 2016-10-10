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
# [*host*]
#   (optional) The gnocchi api bind address.
#   Defaults to 0.0.0.0
#
# [*port*]
#   (optional) The gnocchi api port.
#   Defaults to 8041
#
# [*workers*]
#   (optional) Number of workers for Gnocchi API server.
#   Defaults to $::processorcount
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
# = DEPRECATED PARAMETERS
#
# [*keystone_user*]
#   (optional) DEPRECATED. Use gnocchi::keystone::authtoken::username instead.
#   Defaults to undef
#
# [*keystone_tenant*]
#   (optional) DEPRECATED. Use gnocchi::keystone::authtoken::project_name
#   instead.
#   Defaults to undef
#
# [*keystone_password*]
#   (optional) DEPRECATED. Use gnocchi::keystone::authtoken::password instead.
#   Defaults to undef
#
# [*keystone_auth_uri*]
#   (optional) DEPRECATED. Use gnocchi::keystone::authtoken::auth_uri instead.
#   Defaults to undef
#
# [*keystone_identity_uri*]
#   (optional) DEPRECATED. Use gnocchi::keystone::authtoken::auth_url instead.
#   Defaults to undef
#
class gnocchi::api (
  $manage_service               = true,
  $enabled                      = true,
  $package_ensure               = 'present',
  $host                         = '0.0.0.0',
  $port                         = '8041',
  $workers                      = $::processorcount,
  $max_limit                    = 1000,
  $service_name                 = $::gnocchi::params::api_service_name,
  $sync_db                      = false,
  $auth_strategy                = 'keystone',
  $enable_proxy_headers_parsing = $::os_service_default,
  # DEPRECATED PARAMETERS
  $keystone_user                = undef,
  $keystone_tenant              = undef,
  $keystone_password            = undef,
  $keystone_auth_uri            = undef,
  $keystone_identity_uri        = undef,
) inherits gnocchi::params {

  include ::gnocchi::policy

  if $keystone_identity_uri {
    warning('gnocchi:api::keystone_identity_uri is deprecated, use gnocchi::keystone::authtoken::auth_url instead')
  }

  if $keystone_auth_uri {
    warning('gnocchi::api::keystone_auth_uri is deprecated, use gnocchi::keystone::authtoken::auth_uri instead')
  }

  if $keystone_user {
    warning('gnocchi::api::keystone_user is deprecated, use gnocchi::keystone::authtoken::username instead')
  }

  if $keystone_tenant {
    warning('gnocchi::api::keystone_tenant is deprecated, use gnocchi::keystone::authtoken::project_name instead')
  }

  if $keystone_password {
    warning('gnocchi::api::keystone_password is deprecated, use gnocchi::keystone::authtoken::password instead')
  }

  Gnocchi_config<||> ~> Service[$service_name]
  Gnocchi_api_paste_ini<||> ~> Service[$service_name]
  Class['gnocchi::policy'] ~> Service[$service_name]

  Package['gnocchi-api'] -> Service[$service_name]
  Package['gnocchi-api'] -> Service['gnocchi-api']
  Package['gnocchi-api'] -> Class['gnocchi::policy']
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
      require    => Class['gnocchi::db'],
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
    Class['gnocchi::db'] -> Service[$service_name]
    Service <<| title == 'httpd' |>> { tag +> 'gnocchi-db-sync-service' }

    # we need to make sure gnocchi-api/eventlet is stopped before trying to start apache
    Service['gnocchi-api'] -> Service[$service_name]
  } else {
    fail('Invalid service_name. Either gnocchi/openstack-gnocchi-api for running as a \
          standalone service, or httpd for being run by a httpd server')
  }

  gnocchi_config {
    'api/host':      value => $host;
    'api/port':      value => $port;
    'api/workers':   value => $workers;
    'api/max_limit': value => $max_limit;
  }

  oslo::middleware { 'gnocchi_config':
    enable_proxy_headers_parsing => $enable_proxy_headers_parsing,
  }

  if $auth_strategy == 'keystone' {
    include ::gnocchi::keystone::authtoken
    gnocchi_api_paste_ini {
      'pipeline:main/pipeline':  value => 'gnocchi+auth',
    }
  } else {
    gnocchi_api_paste_ini {
      'pipeline:main/pipeline':  value => 'gnocchi+noauth',
    }
  }

}

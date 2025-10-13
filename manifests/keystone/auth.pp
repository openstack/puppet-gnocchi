# == Class: gnocchi::keystone::auth
#
# Configures Gnocchi user, service and endpoint in Keystone.
#
# === Parameters
#
# [*password*]
#   (Required) Password for gnocchi user.
#
# [*auth_name*]
#   (Optional) Username for gnocchi service.
#   Defaults to 'gnocchi'.
#
# [*email*]
#   (Optional) Email for gnocchi user.
#   Defaults to 'gnocchi@localhost'.
#
# [*tenant*]
#   (Optional) Tenant for gnocchi user.
#   Defaults to 'services'.
#
# [*roles*]
#   (Optional) List of roles assigned to gnocchi user.
#   Defaults to ['admin', 'service']
#
# [*system_scope*]
#   (Optional) Scope for system operations.
#   Defaults to 'all'
#
# [*system_roles*]
#   (Optional) List of system roles assigned to gnocchi user.
#   Defaults to []
#
# [*configure_endpoint*]
#   (Optional) Should gnocchi endpoint be configured?
#   Defaults to true
#
# [*configure_user*]
#   (Optional) Should the service user be configured?
#   Defaults to true
#
# [*configure_user_role*]
#   (Optional) Should the admin role be configured for the service user?
#   Defaults to true
#
# [*configure_service*]
#   (Optional) Should the service be configurd?
#   Defaults to True
#
# [*service_type*]
#   (Optional) Type of service.
#   Defaults to 'metric'.
#
# [*service_name*]
#   (Optional) Name of the service.
#   Defaults to 'gnocchi'
#
# [*service_description*]
#   (Optional) Description for keystone service.
#   Defaults to 'Openstack Metric Service'.
#
# [*region*]
#   (Optional) Region for endpoint.
#   Defaults to 'RegionOne'.
#
# [*public_url*]
#   (Optional) The endpoint's public url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:8041'
#
# [*admin_url*]
#   (Optional) The endpoint's admin url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:8041'
#
# [*internal_url*]
#   (Optional) The endpoint's internal url.
#   This url should *not* contain any trailing '/'.
#   Defaults to 'http://127.0.0.1:8041'
#
class gnocchi::keystone::auth (
  String[1] $password,
  String[1] $auth_name                    = 'gnocchi',
  String[1] $email                        = 'gnocchi@localhost',
  String[1] $tenant                       = 'services',
  Array[String[1]] $roles                 = ['admin', 'service'],
  String[1] $system_scope                 = 'all',
  Array[String[1]] $system_roles          = [],
  Boolean $configure_endpoint             = true,
  Boolean $configure_user                 = true,
  Boolean $configure_user_role            = true,
  Boolean $configure_service              = true,
  String[1] $service_name                 = 'gnocchi',
  String[1] $service_type                 = 'metric',
  String[1] $service_description          = 'OpenStack Metric Service',
  String[1] $region                       = 'RegionOne',
  Keystone::PublicEndpointUrl $public_url = 'http://127.0.0.1:8041',
  Keystone::EndpointUrl $internal_url     = 'http://127.0.0.1:8041',
  Keystone::EndpointUrl $admin_url        = 'http://127.0.0.1:8041',
) {
  include gnocchi::deps

  Keystone::Resource::Service_identity['gnocchi'] -> Anchor['gnocchi::service::end']

  keystone::resource::service_identity { 'gnocchi':
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    configure_endpoint  => $configure_endpoint,
    configure_service   => $configure_service,
    service_name        => $service_name,
    service_type        => $service_type,
    service_description => $service_description,
    region              => $region,
    auth_name           => $auth_name,
    password            => $password,
    email               => $email,
    tenant              => $tenant,
    roles               => $roles,
    system_scope        => $system_scope,
    system_roles        => $system_roles,
    public_url          => $public_url,
    internal_url        => $internal_url,
    admin_url           => $admin_url,
  }
}

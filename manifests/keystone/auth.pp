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
#   Defaults to ['admin']
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
# [*service_type*]
#   (Optional) Type of service.
#   Defaults to 'metric'.
#
# [*region*]
#   (Optional) Region for endpoint.
#   Defaults to 'RegionOne'.
#
# [*service_name*]
#   (Optional) Name of the service.
#   Defaults to 'gnocchi'
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
# [*service_description*]
#   (Optional) Description for keystone service.
#   Defaults to 'Openstack Metric Service'.
#
class gnocchi::keystone::auth (
  $password,
  $auth_name           = 'gnocchi',
  $email               = 'gnocchi@localhost',
  $tenant              = 'services',
  $roles               = ['admin'],
  $system_scope        = 'all',
  $system_roles        = [],
  $configure_endpoint  = true,
  $configure_user      = true,
  $configure_user_role = true,
  $service_name        = 'gnocchi',
  $service_type        = 'metric',
  $region              = 'RegionOne',
  $public_url          = 'http://127.0.0.1:8041',
  $internal_url        = 'http://127.0.0.1:8041',
  $admin_url           = 'http://127.0.0.1:8041',
  $service_description = 'OpenStack Metric Service',
) {

  include gnocchi::deps

  Keystone::Resource::Service_identity['gnocchi'] -> Anchor['gnocchi::service::end']

  keystone::resource::service_identity { 'gnocchi':
    configure_user      => $configure_user,
    configure_user_role => $configure_user_role,
    configure_endpoint  => $configure_endpoint,
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

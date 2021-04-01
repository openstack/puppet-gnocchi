# == Class: gnocchi::policy
#
# Configure the gnocchi policies
#
# === Parameters
#
# [*policies*]
#   (Optional) Set of policies to configure for gnocchi
#   Example :
#     {
#       'gnocchi-context_is_admin' => {
#         'key' => 'context_is_admin',
#         'value' => 'true'
#       },
#       'gnocchi-default' => {
#         'key' => 'default',
#         'value' => 'rule:admin_or_owner'
#       }
#     }
#   Defaults to empty hash.
#
# [*policy_path*]
#   (Optional) Path to the nova policy.yaml file
#   Defaults to /etc/gnocchi/policy.yaml
#
# [*policy_dirs*]
#   (Optional) Path to the gnocchi policy folder
#   Defaults to $::os_service_default
#
class gnocchi::policy (
  $policies    = {},
  $policy_path = '/etc/gnocchi/policy.yaml',
  $policy_dirs = $::os_service_default,
) {

  include gnocchi::deps
  include gnocchi::params

  validate_legacy(Hash, 'validate_hash', $policies)

  # TODO(tkajinam): Remove this once version with policy-in-code implementation
  #                 is released.
  exec { 'gnocci-oslopolicy-convert-json-to-yaml':
    command => "oslopolicy-convert-json-to-yaml --namespace gnocchi --policy-file /etc/gnocchi/policy.json --output-file ${policy_path}",
    unless  => "test -f ${policy_path}",
    path    => ['/bin','/usr/bin','/usr/local/bin'],
    require => Anchor['gnocchi::install::end'],
  }
  Exec<| title == 'gnocchi-oslopolicy-convert-json-to-yaml' |>
  -> File<| title == $policy_path |>

  Openstacklib::Policy::Base {
    file_path   => $policy_path,
    file_user   => 'root',
    file_group  => $::gnocchi::params::group,
    file_format => 'yaml',
  }

  create_resources('openstacklib::policy::base', $policies)

  oslo::policy { 'gnocchi_config':
    policy_file => $policy_path,
    policy_dirs => $policy_dirs,
  }

}

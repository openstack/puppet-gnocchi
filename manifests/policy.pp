# == Class: gnocchi::policy
#
# Configure the gnocchi policies
#
# === Parameters
#
# [*policies*]
#   (optional) Set of policies to configure for gnocchi
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
#   (optional) Path to the nova policy.json file
#   Defaults to /etc/gnocchi/policy.json
#
class gnocchi::policy (
  $policies    = {},
  $policy_path = '/etc/gnocchi/policy.json',
) {

  include ::gnocchi::deps
  include ::gnocchi::params

  validate_hash($policies)

  Openstacklib::Policy::Base {
    file_path  => $policy_path,
    file_user  => 'root',
    file_group => $::gnocchi::params::group,
  }

  create_resources('openstacklib::policy::base', $policies)

  oslo::policy { 'gnocchi_config': policy_file => $policy_path }

}

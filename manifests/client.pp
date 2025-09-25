#
# Installs the gnocchi python library.
#
# == parameters
#  [*ensure*]
#    (optional) ensure state for package.
#    Defaults to 'present'
#
class gnocchi::client (
  Stdlib::Ensure::Package $ensure = 'present'
) {
  include gnocchi::deps
  include gnocchi::params

  package { 'python-gnocchiclient':
    ensure => $ensure,
    name   => $gnocchi::params::client_package_name,
    tag    => ['openstack', 'openstackclient'],
  }

  include openstacklib::openstackclient
}

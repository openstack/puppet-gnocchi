#
# Installs the gnocchi python library.
#
# == parameters
#  [*ensure*]
#    ensure state for package.
#
class gnocchi::client (
  $ensure = 'present'
) {
  include gnocchi::deps
  include gnocchi::params

  package { 'python-gnocchiclient':
    ensure => $ensure,
    name   => $gnocchi::params::client_package_name,
    tag    => 'openstack',
  }

  include openstacklib::openstackclient
}

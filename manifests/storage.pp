# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# gnocchi::storage
#
# Storage backend for Gnocchi
#
# == Parameters
#
# [*package_ensure*]
#   (optional) ensure state for package.
#   Defaults to 'present'
#
# [*coordination_url*]
#   (optional) The url to use for distributed group membership coordination.
#   Defaults to $::os_service_default.
#
# [*metric_processing_delay*]
#   (optional) Delay between processng metrics
#   Defaults to $::os_service_default.
#

class gnocchi::storage(
  $package_ensure          = 'present',
  $coordination_url        = $::os_service_default,
  $metric_processing_delay = $::os_service_default,
) inherits gnocchi::params {

  include ::gnocchi::deps

  if $coordination_url {

    gnocchi_config {
      'storage/coordination_url'        : value => $coordination_url;
      'storage/metric_processing_delay' : value => $metric_processing_delay;
    }

    if ($coordination_url =~ /^redis/ ) {
      ensure_resource('package', 'python-redis', {
        name   => $::gnocchi::params::redis_package_name,
        tag    => 'openstack',
      })

      # NOTE(tobias.urdin): Gnocchi components are packaged with py3 in Ubuntu
      # from Queens.
      if $::operatingsystem == 'Ubuntu' {
        ensure_resource('package', 'python3-redis', {
          name   => 'python3-redis',
          tag    => 'openstack',
        })
      }
    }
  }
}

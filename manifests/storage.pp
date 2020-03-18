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
# DEPRECATED PARAMETERS
#
# [*package_ensure*]
#   (optional) ensure state for package.
#   Defaults to 'present'
#
# [*coordination_url*]
#   (optional) The url to use for distributed group membership coordination.
#   Defaults to undef
#
# [*metric_processing_delay*]
#   (optional) Delay between processng metrics
#   Defaults to undef
#
class gnocchi::storage(
  # DEPRECATED PARAMETERS
  $package_ensure          = undef,
  $coordination_url        = undef,
  $metric_processing_delay = undef,
) inherits gnocchi::params {

  include gnocchi::deps

  if $package_ensure {
    warning('The gnocchi::storage::package_ensure parameter was deprecated. \
Use gnocchi::package_ensure instead')
  }

  if $coordination_url {
    warning('The gnocchi::storage::coordination_url parameter was deprecated. \
Use gnocchi::coordination_url instead')
  }

  if $metric_processing_delay {
    warning('The gnocchi::storage::metric_processing_delay parameter was deprecated. \
Use gnocchi::metricd::metric_processing_delay instead')
  }
}

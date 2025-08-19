#
# Copyright (C) 2015 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
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

# gnocchi::storage::ceph
#
# Ceph driver for Gnocchi
#
# == Parameters
#
# [*ceph_username*]
#   (required) Ceph username to use.
#
# [*ceph_keyring*]
#   (optional) Ceph keyring path.
#   Defaults to undef
#
# [*ceph_secret*]
#   (optional) Ceph secret.
#   Defaults to undef
#
# [*ceph_pool*]
#   (optional) Ceph pool name to use.
#   Defaults to 'gnocchi'.
#
# [*ceph_timeout*]
#   (optional) Ceph connection timeout in seconds.
#   Defaults to $facts['os_service_default']
#
# [*ceph_conffile*]
#   (optional) Ceph configuration file.
#   Defaults to '/etc/ceph/ceph.conf'.
#
# [*manage_rados*]
#   (optional) Ensure state of the rados python package.
#   Defaults to true.
#
# [*package_ensure*]
#   (optional) ensure state for package.
#   Defaults to 'present'
#
class gnocchi::storage::ceph (
  $ceph_username,
  $ceph_keyring         = undef,
  $ceph_secret          = undef,
  $ceph_pool            = 'gnocchi',
  $ceph_timeout         = $facts['os_service_default'],
  $ceph_conffile        = '/etc/ceph/ceph.conf',
  Boolean $manage_rados = true,
  $package_ensure       = 'present',
) inherits gnocchi::params {
  include gnocchi::deps

  if (! $ceph_keyring and ! $ceph_secret) {
    fail('You need to specify either ceph_keyring or ceph_secret.')
  }

  $ceph_keyring_real = $ceph_keyring ? {
    undef   => $facts['os_service_default'],
    default => $ceph_keyring
  }
  $ceph_secret_real = $ceph_secret ? {
    undef   => $facts['os_service_default'],
    default => $ceph_secret
  }

  gnocchi_config {
    'storage/driver':        value => 'ceph';
    'storage/ceph_username': value => $ceph_username;
    'storage/ceph_keyring':  value => $ceph_keyring_real;
    'storage/ceph_secret':   value => $ceph_secret_real, secret => true;
    'storage/ceph_pool':     value => $ceph_pool;
    'storage/ceph_timeout':  value => $ceph_timeout;
    'storage/ceph_conffile': value => $ceph_conffile;
  }

  if $manage_rados {
    stdlib::ensure_packages('python-rados', {
      'ensure' => $package_ensure,
      'name'   => $gnocchi::params::rados_package_name,
      'tag'    => ['openstack','gnocchi-package'],
    })
  }
}

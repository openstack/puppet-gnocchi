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
# [*ceph_pool*]
#   (optional) Ceph pool name to use.
#   Defaults to 'gnocchi'.
#
# [*ceph_username*]
#   (required) Ceph username to use.
#
# [*ceph_keyring*]
#   (optional) Ceph keyring path.
#   Defaults to $::os_service_default
#
# [*ceph_secret*]
#   (optional) Ceph secret.
#   Defaults to $::os_service_default
#
# [*ceph_conffile*]
#   (optional) Ceph configuration file.
#   Defaults to '/etc/ceph/ceph.conf'.
#
# [*manage_rados*]
#   (optional) Ensure state of the rados python package.
#   Defaults to true.
#
# == DEPRECATED PARAMS
#
# [*manage_cradox*]
#   (optional) Ensure state of the cradox package.
#   As of ceph jewel the python-rados package should be used. Option
#   must be set to false for Ubuntu as there is no cradox package for
#   Ubuntu.
#   Defaults to undef.
#
class gnocchi::storage::ceph(
  $ceph_username,
  $ceph_keyring   = $::os_service_default,
  $ceph_secret    = $::os_service_default,
  $ceph_pool      = 'gnocchi',
  $ceph_conffile  = '/etc/ceph/ceph.conf',
  $manage_rados   = true,
  ## DEPRECATED PARAMS
  $manage_cradox  = undef,
) inherits gnocchi::params {

  include gnocchi::deps

  if $manage_cradox != undef {
    warning('gnocchi::storage::ceph::manage_cradox parameter is deprecated and has no effect')
  }

  if (is_service_default($ceph_keyring) and is_service_default($ceph_secret)) or (! $ceph_keyring and ! $ceph_secret) {
    fail('You need to specify either gnocchi::storage::ceph::ceph_keyring or gnocchi::storage::ceph::ceph_secret.')
  }

  gnocchi_config {
    'storage/driver':        value => 'ceph';
    'storage/ceph_username': value => $ceph_username;
    'storage/ceph_keyring':  value => $ceph_keyring;
    'storage/ceph_secret':   value => $ceph_secret, secret => true;
    'storage/ceph_pool':     value => $ceph_pool;
    'storage/ceph_conffile': value => $ceph_conffile;
  }

  if $manage_rados {
    ensure_packages('python-rados', {
      'ensure' => 'present',
      'name'   => $::gnocchi::params::rados_package_name,
      'tag'    => ['openstack','gnocchi-package'],
    })
  }
}

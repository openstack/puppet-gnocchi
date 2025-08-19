#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
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

# gnocchi::storage::swift
#
# Swift driver for Gnocchi
#
# == Parameters
#
# [*swift_auth_version*]
#   (optional) 'Swift authentication version to user.
#   Defaults to $facts['os_service_default']
#
# [*swift_url*]
#   (optional) Swift URL.
#   Defaults to $facts['os_service_default']
#
# [*swift_authurl*]
#   (optional) Swift auth URL.
#   Defaults to $facts['os_service_default']
#
# [*swift_user*]
#   (optional) Swift user.
#   Defaults to $facts['os_service_default']
#
# [*swift_key*]
#   (optional) Swift key.
#   Defaults to $facts['os_service_default']
#
# [*swift_project_name*]
#   (optional) Swift tenant name, only used if swift_auth_version is '2' or
#   '3'.
#   Defaults to $facts['os_service_default']
#
# [*swift_user_domain_name*]
#   (optional) Swift user domain name.
#   Defaults to $facts['os_service_default']
#
# [*swift_project_domain_name*]
#   (optional) Swift project domain name.
#   Defaults to $facts['os_service_default']
#
# [*swift_region*]
#   (optional) Swift region.
#   Defaults to $facts['os_service_default']
#
# [*swift_endpoint_type*]
#   (optional) Swift endpoint type. Defines the keystone endpoint type
#   (publicURL, internalURL or adminURL).
#   Defaults to $facts['os_service_default']
#
# [*swift_service_type*]
#   (optional) A string giving the service type of the swift service to use.
#   Defaults to $facts['os_service_default']
#
# [*swift_timeout*]
#   (optional) Connection timeout in seconds.
#   Defaults to $facts['os_service_default']
#
# [*swift_container_prefix*]
#   (optional) Prefix to namespace metric containers.
#   Defaults to $facts['os_service_default']
#
class gnocchi::storage::swift (
  $swift_auth_version        = $facts['os_service_default'],
  $swift_url                 = $facts['os_service_default'],
  $swift_authurl             = $facts['os_service_default'],
  $swift_user                = $facts['os_service_default'],
  $swift_key                 = $facts['os_service_default'],
  $swift_project_name        = $facts['os_service_default'],
  $swift_user_domain_name    = $facts['os_service_default'],
  $swift_project_domain_name = $facts['os_service_default'],
  $swift_region              = $facts['os_service_default'],
  $swift_endpoint_type       = $facts['os_service_default'],
  $swift_service_type        = $facts['os_service_default'],
  $swift_timeout             = $facts['os_service_default'],
  $swift_container_prefix    = $facts['os_service_default'],
) {
  include gnocchi::deps

  gnocchi_config {
    'storage/driver':                    value => 'swift';
    'storage/swift_user':                value => $swift_user;
    'storage/swift_key':                 value => $swift_key, secret => true;
    'storage/swift_project_name':        value => $swift_project_name;
    'storage/swift_user_domain_name':    value => $swift_user_domain_name;
    'storage/swift_project_domain_name': value => $swift_project_domain_name;
    'storage/swift_region':              value => $swift_region;
    'storage/swift_auth_version':        value => $swift_auth_version;
    'storage/swift_url':                 value => $swift_url;
    'storage/swift_authurl':             value => $swift_authurl;
    'storage/swift_endpoint_type':       value => $swift_endpoint_type;
    'storage/swift_service_type':        value => $swift_service_type;
    'storage/swift_timeout':             value => $swift_timeout;
    'storage/swift_container_prefix':    value => $swift_container_prefix;
  }
}

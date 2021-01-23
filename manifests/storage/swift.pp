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
#   Defaults to $::os_service_default
#
# [*swift_authurl*]
#   (optional) Swift auth URL.
#   Defaults to $::os_service_default
#
# [*swift_user*]
#   (optional) Swift user.
#   Defaults to $::os_service_default
#
# [*swift_key*]
#   (optional) Swift key.
#   Defaults to $::os_service_default
#
# [*swift_project_name*]
#   (optional) Swift tenant name, only used if swift_auth_version is '2' or
#   '3'.
#   Defaults to $::os_service_default
#
# [*swift_user_domain_name*]
#   (optional) Swift user domain name.
#   Defaults to $::os_service_default
#
# [*swift_project_domain_name*]
#   (optional) Swift project domain name.
#   Defaults to $::os_service_default
#
# [*swift_region*]
#   (optional) Swift region.
#   Defaults to $::os_service_default
#
# [*swift_endpoint_type*]
#   (optional) Swift endpoint type. Defines the keystone endpoint type
#   (publicURL, internalURL or adminURL).
#   Defaults to $::os_service_default
#
# [*swift_service_type*]
#   (optional) A string giving the service type of the swift service to use.
#   Defaults to $::os_service_default
#
# [*swift_timeout*]
#   (optional) Connection timeout in seconds.
#   Defaults to $::os_service_default
#
# DEPRECATED PARAMETERS
#
# [*swift_tenant_name*]
#   (optional) Swift tenant name, only used if swift_auth_version is '2' or
#   '3'.
#   Defaults to undef
#
class gnocchi::storage::swift(
  $swift_auth_version        = $::os_service_default,
  $swift_authurl             = $::os_service_default,
  $swift_user                = $::os_service_default,
  $swift_key                 = $::os_service_default,
  $swift_project_name        = $::os_service_default,
  $swift_user_domain_name    = $::os_service_default,
  $swift_project_domain_name = $::os_service_default,
  $swift_region              = $::os_service_default,
  $swift_endpoint_type       = $::os_service_default,
  $swift_service_type        = $::os_service_default,
  $swift_timeout             = $::os_service_default,
  # DEPRECATED PARAMETERS
  $swift_tenant_name         = undef,
) {

  include gnocchi::deps

  if $swift_tenant_name != undef {
    warning('gnocchi::storage::swift::swift_tenant_name is deprecated and \
will be removed in a future release. Use swift_project_name instead')
    $swift_project_name_real = $swift_tenant_name
  } else {
    $swift_project_name_real = $swift_project_name
  }

  gnocchi_config {
    'storage/driver':                    value => 'swift';
    'storage/swift_user':                value => $swift_user;
    'storage/swift_key':                 value => $swift_key;
    'storage/swift_project_name':        value => $swift_project_name_real;
    'storage/swift_user_domain_name':    value => $swift_user_domain_name;
    'storage/swift_project_domain_name': value => $swift_project_domain_name;
    'storage/swift_region':              value => $swift_region;
    'storage/swift_auth_version':        value => $swift_auth_version;
    'storage/swift_authurl':             value => $swift_authurl;
    'storage/swift_endpoint_type':       value => $swift_endpoint_type;
    'storage/swift_service_type':        value => $swift_service_type;
    'storage/swift_timeout':             value => $swift_timeout;
  }

}

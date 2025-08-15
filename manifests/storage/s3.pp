#
# gnocchi::storage::s3
#
# S3 driver for Gnocchi
#
# == Parameters
#
# [*s3_endpoint_url*]
#   (optional) 'S3 endpoint url.
#   Defaults to $facts['os_service_default']
#
# [*s3_region_name*]
#   (optional) S3 Region name.
#   Defaults to $facts['os_service_default']
#
# [*s3_access_key_id*]
#   (optional) S3 storage access key id.
#   Defaults to undef
#
# [*s3_secret_access_key*]
#   (optional) S3 storage secret access key.
#   Defaults to undef
#
# [*s3_bucket_prefix*]
#   (optional) S3 bucket prefix for gnocchi
#   Defaults to undef
#
# [*manage_boto3*]
#   (optional) Manage boto3 package.
#   Defaults to true
#
# [*package_ensure*]
#   (optional) The state of boto3 package.
#   Defaults to 'present'
#
class gnocchi::storage::s3(
  $s3_endpoint_url      = $facts['os_service_default'],
  $s3_region_name       = $facts['os_service_default'],
  $s3_access_key_id     = undef,
  $s3_secret_access_key = undef,
  $s3_bucket_prefix     = $facts['os_service_default'],
  Boolean $manage_boto3 = true,
  $package_ensure       = 'present',
) {

  include gnocchi::deps
  include gnocchi::params

  if $manage_boto3 {
    stdlib::ensure_packages('python-boto3', {
      'ensure' => $package_ensure,
      'name'   => $gnocchi::params::boto3_package_name,
      'tag'    => ['openstack','gnocchi-package'],
    })
  }

  gnocchi_config {
    'storage/driver':                value => 's3';
    'storage/s3_endpoint_url':       value => $s3_endpoint_url;
    'storage/s3_region_name':        value => $s3_region_name;
    'storage/s3_access_key_id':      value => $s3_access_key_id, secret => true;
    'storage/s3_secret_access_key':  value => $s3_secret_access_key, secret => true;
    'storage/s3_bucket_prefix':      value => $s3_bucket_prefix;
  }

}

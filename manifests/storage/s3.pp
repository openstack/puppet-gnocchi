#
# gnocchi::storage::s3
#
# S3 driver for Gnocchi
#
# == Parameters
#
# [*s3_endpoint_url*]
#   (optional) 'S3 endpoint url.
#   Defaults to $::os_service_default
#
# [*s3_region_name*]
#   (optional) S3 Region name.
#   Defaults to $::os_service_default
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
class gnocchi::storage::s3(
  $s3_endpoint_url      = $::os_service_default,
  $s3_region_name       = $::os_service_default,
  $s3_access_key_id     = undef,
  $s3_secret_access_key = undef,
  $s3_bucket_prefix     = $::os_service_default,
) {

  include ::gnocchi::deps

  gnocchi_config {
    'storage/driver':                value => 's3';
    'storage/s3_endpoint_url':       value => $s3_endpoint_url;
    'storage/s3_region_name':        value => $s3_region_name;
    'storage/s3_access_key_id':      value => $s3_access_key_id;
    'storage/s3_secret_access_key':  value => $s3_secret_access_key, secret => true;
    'storage/s3_bucket_prefix':      value => $s3_bucket_prefix;
  }

}

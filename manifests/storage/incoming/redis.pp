#
# gnocchi::storage::incoming::redis
#
# Redis incoming storage driver for Gnocchi
#
# == Parameters
#
# [*redis_url*]
#   (optional) Redis url.
#
class gnocchi::storage::incoming::redis(
  $redis_url = undef,
) {

  include ::gnocchi::deps

  gnocchi_config {
    'incoming/driver':        value => 'redis';
    'incoming/redis_url':     value => $redis_url;
  }

}

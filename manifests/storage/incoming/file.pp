#
# gnocchi::storage::incoming::file
#
# File incoming storage driver for Gnocchi
#
# == Parameters
#
# [*file_basepath*]
#   (optional) Path used to store gnocchi data files.
#   This parameter can be used only when gnocchi::storage::file is not used.
#   Defaults to $facts['os_service_default'].
#
class gnocchi::storage::incoming::file(
  $file_basepath = $facts['os_service_default'],
) {

  include gnocchi::deps

  gnocchi_config {
    'incoming/driver':        value => 'file';
    'incoming/file_basepath': value => $file_basepath;
  }

}

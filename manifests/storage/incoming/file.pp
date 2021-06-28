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
#   Defaults to undef
#
class gnocchi::storage::incoming::file(
  $file_basepath = undef,
) {

  include gnocchi::deps

  # Because the file_basepath parameter is maintained by two classes, here we
  # skip the parameter unless a user explicitly requests it, to avoid
  # duplicated declaration.
  if $file_basepath != undef {
    gnocchi_config {
      'storage/file_basepath': value => $file_basepath;
    }
  }

  gnocchi_config {
    'incoming/driver': value => 'file';
  }

}

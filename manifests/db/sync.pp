#
# Class to execute "gnocchi-dbsync"
#
# [*user*]
#   (Optional) User to run dbsync command.
#   Defaults to 'gnocchi'
#
# [*extra_opts*]
#   (Optional) String of extra command line parameters to append
#   to the gnocchi-db-sync command.
#   Defaults to undef
#
# [*db_sync_timeout*]
#   (Optional) Timeout for the execution of the db_sync
#   Defaults to 300
#
class gnocchi::db::sync (
  $user            = 'gnocchi',
  $extra_opts      = undef,
  $db_sync_timeout = 300,
){

  include gnocchi::deps

  exec { 'gnocchi-db-sync':
    command     => "gnocchi-upgrade --config-file /etc/gnocchi/gnocchi.conf ${extra_opts}",
    path        => '/usr/bin',
    refreshonly => true,
    user        => $user,
    try_sleep   => 5,
    tries       => 10,
    timeout     => $db_sync_timeout,
    logoutput   => on_failure,
    subscribe   => [
      Anchor['gnocchi::install::end'],
      Anchor['gnocchi::config::end'],
      Anchor['gnocchi::dbsync::begin']
    ],
    notify      => Anchor['gnocchi::dbsync::end'],
    tag         => 'openstack-db',
  }

}

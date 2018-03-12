#
# Class to execute "gnocchi-dbsync"
#
# [*user*]
#   (optional) User to run dbsync command.
#   Defaults to 'gnocchi'
#
# [*extra_opts*]
#   (optional) String of extra command line parameters to append
#   to the gnocchi-db-sync command.
#   Defaults to undef

class gnocchi::db::sync (
  $user       = 'gnocchi',
  $extra_opts = undef,
){

  include ::gnocchi::deps

  exec { 'gnocchi-db-sync':
    command     => "gnocchi-upgrade --config-file /etc/gnocchi/gnocchi.conf ${extra_opts}",
    path        => '/usr/bin',
    refreshonly => true,
    user        => $user,
    try_sleep   => 5,
    tries       => 10,
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

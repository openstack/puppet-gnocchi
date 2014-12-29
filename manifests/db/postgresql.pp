# == Class: gnocchi::db::postgresql
#
# Manage the gnocchi postgresql database
#
# === Parameters:
#
# [*password*]
#   (required) Password that will be used for the gnocchi db user.
#
# [*dbname*]
#   (optionnal) Name of gnocchi database.
#   Defaults to gnocchi
#
# [*user*]
#   (optionnal) Name of gnocchi user.
#   Defaults to gnocchi
#
class gnocchi::db::postgresql(
  $password,
  $dbname    = 'gnocchi',
  $user      = 'gnocchi'
) {

  require postgresql::python

  Class['gnocchi::db::postgresql'] -> Service<| title == 'gnocchi' |>
  Postgresql::Db[$dbname] ~> Exec<| title == 'gnocchi-dbsync' |>
  Package['python-psycopg2'] -> Exec<| title == 'gnocchi-dbsync' |>


  postgresql::db { $dbname:
    user      => $user,
    password  => $password,
  }

}

# == Class: gnocchi::deps
#
#  Gnocchi anchors and dependency management
#
class gnocchi::deps {
  # Setup anchors for install, config and service phases of the module.  These
  # anchors allow external modules to hook the begin and end of any of these
  # phases.  Package or service management can also be replaced by ensuring the
  # package is absent or turning off service management and having the
  # replacement depend on the appropriate anchors.  When applicable, end tags
  # should be notified so that subscribers can determine if installation,
  # config or service state changed and act on that if needed.
  anchor { 'gnocchi::install::begin': }
  -> Package<| tag == 'gnocchi-package'|>
  ~> anchor { 'gnocchi::install::end': }
  -> anchor { 'gnocchi::config::begin': }
  -> Gnocchi_config<||>
  ~> anchor { 'gnocchi::config::end': }
  -> anchor { 'gnocchi::db::begin': }
  -> anchor { 'gnocchi::db::end': }
  ~> anchor { 'gnocchi::dbsync::begin': }
  -> anchor { 'gnocchi::dbsync::end': }
  ~> anchor { 'gnocchi::service::begin': }
  ~> Service<| tag == 'gnocchi-service' |>
  ~> anchor { 'gnocchi::service::end': }

  # policy config should occur in the config block also.
  Anchor['gnocchi::config::begin']
  -> Openstacklib::Policy::Base<||>
  ~> Anchor['gnocchi::config::end']

  # Installation or config changes will always restart services.
  Anchor['gnocchi::install::end'] ~> Anchor['gnocchi::service::begin']
  Anchor['gnocchi::config::end']  ~> Anchor['gnocchi::service::begin']
}

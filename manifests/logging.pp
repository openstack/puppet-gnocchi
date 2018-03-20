# Class gnocchi::logging
#
#  gnocchi logging configuration
#
# == parameters
#
#  [*debug*]
#    (Optional) Should the daemons log debug messages
#    Defaults to $::os_service_default
#
#  [*use_syslog*]
#    (Optional) Use syslog for logging.
#    Defaults to $::os_service_default
#
#  [*use_json*]
#    (Optional) Use json for logging.
#    Defaults to $::os_service_default
#
#  [*use_journal*]
#    (Optional) Use journal for logging.
#    Defaults to $::os_service_default
#
#  [*use_stderr*]
#    (optional) Use stderr for logging
#    Defaults to $::os_service_default
#
#  [*log_facility*]
#    (Optional) Syslog facility to receive log lines.
#    Defaults to $::os_service_default
#
#  [*log_dir*]
#    (optional) Directory where logs should be stored.
#    If set to boolean false or the $::os_service_default, it will not log to
#    any directory.
#    Defaults to '/var/log/gnocchi'
#
class gnocchi::logging(
  $use_syslog                    = $::os_service_default,
  $use_json                      = $::os_service_default,
  $use_journal                   = $::os_service_default,
  $use_stderr                    = $::os_service_default,
  $log_facility                  = $::os_service_default,
  $log_dir                       = '/var/log/gnocchi',
  $debug                         = $::os_service_default,
) {

  include ::gnocchi::deps

  # note(spredzy): in order to keep backward compatibility we rely on the pick function
  # to use gnocchi::<myparam> first then gnocchi::logging::<myparam>.
  $use_syslog_real   = pick($::gnocchi::use_syslog,$use_syslog)
  $use_stderr_real   = pick($::gnocchi::use_stderr,$use_stderr)
  $log_facility_real = pick($::gnocchi::log_facility,$log_facility)
  if $log_dir != '' {
    $log_dir_real = pick($::gnocchi::log_dir,$log_dir)
  } else {
    $log_dir_real = $log_dir
  }
  $debug_real        = pick($::gnocchi::debug,$debug)

  oslo::log { 'gnocchi_config':
    debug               => $debug_real,
    use_syslog          => $use_syslog_real,
    use_json            => $use_json,
    use_journal         => $use_journal,
    use_stderr          => $use_stderr_real,
    log_dir             => $log_dir_real,
    syslog_log_facility => $log_facility_real,
  }

}

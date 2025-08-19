# Class gnocchi::logging
#
#  gnocchi logging configuration
#
# == parameters
#
# [*debug*]
#   (Optional) Should the daemons log debug messages
#   Defaults to $facts['os_service_default']
#
# [*use_syslog*]
#   (Optional) Use syslog for logging.
#   Defaults to $facts['os_service_default']
#
# [*use_json*]
#   (Optional) Use json for logging.
#   Defaults to $facts['os_service_default']
#
# [*use_journal*]
#   (Optional) Use journal for logging.
#   Defaults to $facts['os_service_default']
#
# [*use_stderr*]
#   (Optional) Use stderr for logging
#   Defaults to $facts['os_service_default']
#
# [*log_facility*]
#   (Optional) Syslog facility to receive log lines.
#   Defaults to $facts['os_service_default']
#
# [*log_dir*]
#   (Optional) Directory where logs should be stored.
#   If set to boolean false or the $facts['os_service_default'], it will not log to
#   any directory.
#   Defaults to '/var/log/gnocchi'
#
# [*log_file*]
#   (Optional) File where logs should be stored.
#   Defaults to $facts['os_service_default']
#
class gnocchi::logging (
  $use_syslog   = $facts['os_service_default'],
  $use_json     = $facts['os_service_default'],
  $use_journal  = $facts['os_service_default'],
  $use_stderr   = $facts['os_service_default'],
  $log_facility = $facts['os_service_default'],
  $log_dir      = '/var/log/gnocchi',
  $log_file     = $facts['os_service_default'],
  $debug        = $facts['os_service_default'],
) {
  include gnocchi::deps

  oslo::log { 'gnocchi_config':
    debug               => $debug,
    use_syslog          => $use_syslog,
    use_json            => $use_json,
    use_journal         => $use_journal,
    use_stderr          => $use_stderr,
    log_dir             => $log_dir,
    log_file            => $log_file,
    syslog_log_facility => $log_facility,
  }
}

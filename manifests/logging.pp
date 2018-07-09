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
#  DEPRECATED PARAMETERS
#
#  [*logging_context_format_string*]
#    (optional) format string to use for log messages with context.
#    Defaults to undef
#    example: '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s\
#              [%(request_id)s %(user_identity)s] %(instance)s%(message)s'
#
#  [*logging_default_format_string*]
#    (optional) format string to use for log messages without context.
#    Defaults to undef
#    example: '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s\
#              [-] %(instance)s%(message)s'
#
#  [*logging_debug_format_suffix*]
#    (optional) formatted data to append to log format when level is debug.
#    Defaults to undef
#    example: '%(funcname)s %(pathname)s:%(lineno)d'
#
#  [*logging_exception_prefix*]
#    (optional) prefix each line of exception output with this format.
#    Defaults to undef
#    example: '%(asctime)s.%(msecs)03d %(process)d trace %(name)s %(instance)s'
#
#  [*log_config_append*]
#    the name of an additional logging configuration file.
#    Defaults to undef
#    see https://docs.python.org/2/howto/logging.html
#
#  [*default_log_levels*]
#    (optional) hash of logger (keys) and level (values) pairs.
#    Defaults to undef
#    example:
#      { 'amqp' => 'warn', 'amqplib' => 'warn', 'boto' => 'warn',
#        'sqlalchemy' => 'warn', 'suds' => 'info', 'iso8601' => 'warn',
#        'requests.packages.urllib3.connectionpool' => 'warn' }
#
#  [*publish_errors*]
#    (optional) publish error events (boolean value).
#    Defaults to undef
#
#  [*fatal_deprecations*]
#    (optional) make deprecations fatal (boolean value)
#    Defaults to undef
#
#  [*instance_format*]
#    (optional) if an instance is passed with the log message, format it
#               like this (string value).
#    Defaults to undef
#    example: '[instance: %(uuid)s] '
#
#  [*instance_uuid_format*]
#    (optional) if an instance uuid is passed with the log message, format
#               it like this (string value).
#    Defaults to undef
#    example: instance_uuid_format='[instance: %(uuid)s] '
#
#  [*log_date_format*]
#    (optional) format string for %%(asctime)s in log records.
#    Defaults to undef
#    example: 'y-%m-%d %h:%m:%s'
#
class gnocchi::logging(
  $use_syslog                    = $::os_service_default,
  $use_json                      = $::os_service_default,
  $use_journal                   = $::os_service_default,
  $use_stderr                    = $::os_service_default,
  $log_facility                  = $::os_service_default,
  $log_dir                       = '/var/log/gnocchi',
  $debug                         = $::os_service_default,
  # DEPRECATED
  $logging_context_format_string = undef,
  $logging_default_format_string = undef,
  $logging_debug_format_suffix   = undef,
  $logging_exception_prefix      = undef,
  $log_config_append             = undef,
  $default_log_levels            = undef,
  $publish_errors                = undef,
  $fatal_deprecations            = undef,
  $instance_format               = undef,
  $instance_uuid_format          = undef,
  $log_date_format               = undef,
) {

  include ::gnocchi::deps

  if $logging_context_format_string {
    warning('gnocchi::logging::logging_context_format_string is deprecated and will be removed in future')
  }

  if $logging_default_format_string {
    warning('gnocchi::logging::logging_default_format_string is deprecated and will be removed in future')
  }

  if $logging_debug_format_suffix {
    warning('gnocchi::logging::logging_debug_format_suffix is deprecated and will be removed in future')
  }

  if $logging_exception_prefix {
    warning('gnocchi::logging::logging_exception_prefix is deprecated and will be removed in future')
  }

  if $log_config_append {
    warning('gnocchi::logging::log_config_append is deprecated and will be removed in future')
  }

  if $default_log_levels {
    warning('gnocchi::logging::default_log_levels is deprecated and will be removed in future')
  }

  if $publish_errors {
    warning('gnocchi::logging::publish_errors is deprecated and will be removed in future')
  }

  if $fatal_deprecations {
    warning('gnocchi::logging::fatal_deprecations is deprecated and will be removed in future')
  }

  if $instance_format {
    warning('gnocchi::logging::instance_format is deprecated and will be removed in future')
  }

  if $instance_uuid_format {
    warning('gnocchi::logging::instance_uuid_format is deprecated and will be removed in future')
  }

  if $log_date_format {
    warning('gnocchi::logging::log_date_format is deprecated and will be removed in future')
  }

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

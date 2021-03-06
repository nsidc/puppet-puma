# puma::params class
class puma::params {
  $puma_user          = 'puma'
  $www_user           = 'www-data'
  $min_threads        = 1
  $max_threads        = 16
  $port               = 9292
  $workers            = 1
  $init_active_record = false
  $preload_app        = true
  $rails_env          = $environment
  $rvm_ruby           = false
  $restart_command    = 'puma'
  $bundler_path       = '/usr/local/bin/bundle'

  if $::nx_daemon_user {
    $www_user = $::nx_daemon_user # Assume nginx user if available
  }

  case $::osfamily {
    'Debian': {
      $app_root_spf      = '/var/www/%s'
      $puma_pid_path_spf    = '/var/run/%s/puma.pid'
      $puma_socket_path_spf  = '/var/run/%s/puma.socket'
      $puma_config_path_spf  = '/etc/%s/puma.rb'
      $puma_stdout_log_path_spf = '/var/log/%s.puma.stdout.log'
      $puma_stderr_log_path_spf = '/var/log/%s.puma.stderr.log'
      $init_script_spf    = '/etc/init.d/%s'
      case $::operatingsystem {
        'Ubuntu': {
          if $::operatingsystemmajrelease >= '15.04' {
            $service_type   = 'systemd'
          } else {
            $service_type   = 'upstart'
          }
        }
        default: {
          $service_type   = 'sysv'
        }
      }
    }
    default: {
      fail("${::osfamily} is not supported - \
           now would be a great time to look into using module_data")
    }

  }
}

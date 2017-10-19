# puma::nginxconfig
define puma::nginxconfig(
  $app_name     = $title,
  $server_name    = [$title],
  $public_root  = join([sprintf($puma::app_root_spf, $title), 'public'], '/'),
) {
  $puma_socket_path = sprintf($puma::puma_socket_path_spf, $app_name)

  $upstream_name = "${app_name}_socket"
  $vhost_name = $app_name

  nginx::resource::upstream {$upstream_name:
    ensure                => present,
    members               => ["unix://${puma_socket_path}"],
    upstream_fail_timeout => '10s',
  }


  nginx::resource::vhost { $vhost_name:
    ensure               => present,
    server_name          => $server_name,
    www_root             => $public_root,
    use_default_location => false,
    index_files          => [],
  }

  nginx::resource::location { "${vhost_name}:assets":
    ensure                     => present,
    location                   => '~ ^/(assets)/',
    vhost                      => $vhost_name,
    priority                   => 499,
    location_custom_cfg        => {
      'access_log'  => 'off',
      'expires'     => 'max',
      'add_header'  => 'Cache-Control "public"',
      'add_header'  => 'Etag ""',
      'gzip_static' => 'on',
    },
    location_custom_cfg_append => {
      'if' => '($request_filename ~* ^.*?\.(eot)|(ttf)|(woff)|(svg)|(otf)$){
        add_header Access-Control-Allow-Origin *;
      }
      '
    },
  }

  nginx::resource::location { "${vhost_name}:root":
    ensure              => present,
    location            => '/',
    vhost               => $vhost_name,
    priority            => 500,
    location_custom_cfg => {
      try_files => ['$uri @rails']
    }
  }

  nginx::resource::location { "${vhost_name}:rails":
    ensure              => present,
    location            => '@rails',
    priority            => 501,
    vhost               => $vhost_name,
    proxy               => "http://${upstream_name}",
    proxy_read_timeout  => '90',
    location_cfg_append => {
      'proxy_http_version' => '1.1',
      'proxy_set_header'   => [
        'Host $host',
        'X-Forwarded-For $proxy_add_x_forwarded_for',
        # Thought this was needed for SSL but it is causing an infinite loop
        # 'X-Forwarded-Proto $scheme'
      ],
    },
  }
}

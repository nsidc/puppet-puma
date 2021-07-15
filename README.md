# puma

## Overview

Configure puma servers for Ruby-on-Rails apps.

Configures the application as a system service (`upstart`, `systemd`, or good old `sysv`).

Configurations for Debian-family systems included, patches welcome for other OSes.

For a more comprehensive Rails deployment recipe which makes use of this module, see [`deversus-rails`](https://forge.puppetlabs.com/deversus/rails).

## Dependencies
The following gems should be installed prior to use of the `puma::app` resource:

* puma >= 5.0.0
* bundler

## Optional Dependencies

* RVM support requires `maestrodev-rvm (~> v1.5.5)` .
* NGINX support requires `jfryman-nginx (~> v0.0.9)`.

Patches welcome for servers other than NGINX.

## Usage


```puppet
# Debian default values shown (except rvm, which defaults to false)
puma::app {'myapp':
    app_name           => 'myapp',
    app_root           => '/var/www/myapp/current',
    puma_user          => 'puma',
    www_user           => 'www-data',
    min_threads        => 1,
    max_threads        => 16,
    port               => 9292,
    workers            => 1,
    init_active_record => false,
    preload_app        => true,
    rails_env          => 'production',
    rvm_ruby           => 'ruby-2.0.0-p0',
    restart_command    => 'puma',
    bundler_path       => '/usr/local/bin/bundler'
}

```

This would install a service called `myapp` (in `/etc/init` if `upstart` is used,  `/etc/systemd/system/` ,or `/etc/init.d` for init). Socket and PID files will be put in `/var/run/myapp/`. Log files will be put in `/var/log/myapp.puma.stdout.log` etc.

An RVM ruby environment for `ruby-2.0.0-p0` will be installed if needed and used to launch puma. (with `rvm_ruby => false`, system ruby will be used)

If you need to use a version of bundler other than the one at `/usr/local/bin/bundler`, specify it in the config like `bundler_path => '/usr/local/rbenv/shims/bundler'`.

### Configuring NGINX

A convenience resource for configuring NGINX for the above setup is provided:

```puppet
# Debian default values shown
puma::nginxconfig {'myapp':
    server_name     => ['www.myapp.com'],
    public_root     => '/var/www/myapp/current/public',
}
```

This will create the necessary NGINX vhost and location configurations to serve a puma rails app.

## Release Management

The [`bump` gem](https://github.com/gregorym/bump) is used to manage version information in
`CHANGELOG`, `metadata.json`, and Git tags. Currently this is a manual process. Insert a
description of your changes at the top of the `CHANGELOG` file, leaving a blank line between
your new description and the previous version entry. No header markup is necessary (`bump`
will add it). Then do:

```
bundle install --gemfile=Gemfile_common # install bump gem if necessary
bump <level> --tag --tag-prefix v --changelog --replace-in metadata.json # <level> is major, minor, or patch
git push # push updated version tags etc. to origin
```

Other useful `bump` options:

```
bump current # show current version
bump show-next patch # Show next version for specified bump level
bump file # Show file used as version reference.
```

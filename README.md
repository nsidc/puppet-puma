# puma

## Overview

Configure puma servers for Ruby-on-Rails apps.

Configures the application as a system service (`upstart`, `systemd`, or good old `sysv`).

Configurations for Debian-family systems included, patches welcome for other OSes.

For a more comprehensive Rails deployment recipe which makes use of this module, see [`deversus-rails`](https://forge.puppetlabs.com/deversus/rails).

## Dependencies
This version supports Puppet 8; older versions of puppet are no longer supported by this module. To use an older version of puppet, you can use a tagged version (such as `puppet7`), but they will not be maintained further.

The following gems should be installed prior to use of the `puma::app` resource:

* puma >= 5.0.0 (higher versions recommended when possible)
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
    rvm_ruby           => 'ruby-3.4.9',
    restart_command    => 'puma',
    bundler_path       => '/usr/local/bin/bundler'
}

```

This would install a service called `myapp` (in `/etc/init` if `upstart` is used,  `/etc/systemd/system/` ,or `/etc/init.d` for init). Socket and PID files will be put in `/var/run/myapp/`. Log files will be put in `/var/log/myapp.puma.stdout.log` etc.

An RVM ruby environment for `ruby-3.4.9` will be installed if needed and used to launch puma. (with `rvm_ruby => false`, system ruby will be used)

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
git push origin v<new version number> # push updated version tag to origin
```

Other useful `bump` options:

```
bump current # show current version
bump show-next patch # Show next version for specified bump level
bump file # Show file used as version reference.
```

## Testing

This module runs tests with GitHub Actions after each push; these tests mostly
just check for proper puppet linting and syntax.

To run those tests locally, things have been wrapped into a Docker container.
You can run the tests like this:

```
docker-compose run lint
docker-compose run validate
```

### Testing against a dev VM project

The `vadr` project at NSIDC uses `puppet-puma` and can be used to test changes. 

Update that project's Puppetfile with the ref of the branch you want to test, then bring up a dev VM:

```
cd /path/to/vadr-repo/
vagrant nsidc up --env=dev
```

Once the machine is up, confirm the puma app is running by navigating to
(subsituting in your username):
<http://dev.vadr.{YOUR_USERNAME}.dev.int.nsidc.org/>. If you see an API doc page
for vadr, then the plugin updates probably worked! Be sure to check the logs for
any errors/warnings.

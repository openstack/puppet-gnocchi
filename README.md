puppet-gnocchi
==============

#### Table of Contents

1. [Overview - What is the gnocchi module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with gnocchi](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors - Those with commits](#contributors)

Overview
--------

The gnocchi module is a part of [OpenStack](https://github.com/openstack), an effort by the OpenStack infrastructure team to provide continuous integration testing and code review for OpenStack and OpenStack community projects as part of the core software. The module itself is used to flexibly configure and manage the management service for OpenStack.

Module Description
------------------

Setup
-----

**What the gnocchi module affects:**

* [Gnocchi](http://docs.openstack.org/developer/gnocchi/), the HTTP API to store metrics and index resources for OpenStack
  (OpenStack Datapoint Service).

### Installing gnocchi

    puppet module install openstack/gnocchi

Implementation
--------------

### gnocchi

gnocchi is a combination of Puppet manifest and ruby code to delivery configuration and extra functionality through types and providers.

### Types

#### gnocchi_config

The `gnocchi_config` provider is a children of the ini_setting provider. It allows one to write an entry in the `/etc/gnocchi/gnocchi.conf` file.

```puppet
gnocchi_config { 'DEFAULT/debug' :
  value => true,
}
```

This will write `debug=true` in the `[DEFAULT]` section.

##### name

Section/setting name to manage from `gnocchi.conf`

##### value

The value of the setting to be defined.

##### secret

Whether to hide the value from Puppet logs. Defaults to `false`.

##### ensure_absent_val

If value is equal to ensure_absent_val then the resource will behave as if `ensure => absent` was specified. Defaults to `<SERVICE DEFAULT>`

Limitations
-----------

### Load balancing Gnocchi MySQL with HAProxy

#### Issue

MySQL client/server interaction causes an issue where the HAProxy server will keep a connection in TIME_WAIT. When Gnocchi is processing data it will generate a lot of connections to MySQL and [exhaust all available tcp ports](http://blog.haproxy.com/2012/12/12/haproxy-high-mysql-request-rate-and-tcp-source-port-exhaustion/) for a given IP address. If the HAProxy VIP is shared with other components, this can cause them to be unavailable too. Tuning of HAProxy instance is essential when using Gnocchi with a MySQL behind an HAProxy.

The sysctl parameters need tuning.

* net.ipv4.tcp_tw_reuse = 1
* net.core.somaxconn = 4096
* net.ipv4.tcp_max_syn_backlog = 60000

Additionally, HAProxy can be configured to use different source IP addresses on each backend to help further mitigate the issue.

Development
-----------

Developer documentation for the entire puppet-openstack project.

* http://docs.openstack.org/developer/puppet-openstack-guide/

Contributors
------------

The github [contributor graph](https://github.com/openstack/puppet-gnocchi/graphs/contributors).

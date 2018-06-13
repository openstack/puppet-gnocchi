# This is an example of site.pp to deploy Gnocchi

class { '::gnocchi::keystone::auth':
  admin_url    => 'http://10.0.0.1:8041',
  internal_url => 'http://10.0.0.1:8041',
  public_url   => 'http://10.0.0.1:8041',
  password     => 'verysecrete',
  region       => 'OpenStack'
}

class { '::gnocchi':
  database_connection => 'mysql+pymysql://gnocchi:secrete@10.0.0.1/gnocchi?charset=utf8',
}

class { '::gnocchi::api':
  bind_host         => '10.0.0.1',
  identity_uri      => 'https://identity.openstack.org:5000',
  keystone_password => 'verysecrete'
}

class { '::gnocchi::statsd':
  resource_id         => '07f26121-5777-48ba-8a0b-d70468133dd9',
  archive_policy_name => 'high',
  flush_delay         => '100',
}

include ::gnocchi::client

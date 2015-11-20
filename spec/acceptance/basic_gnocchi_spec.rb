require 'spec_helper_acceptance'

describe 'basic gnocchi' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      # Common resources
      case $::osfamily {
        'Debian': {
          include ::apt
          class { '::openstack_extras::repo::debian::ubuntu':
            release         => 'liberty',
            repo            => 'proposed',
            package_require => true,
          }
        }
        'RedHat': {
          class { '::openstack_extras::repo::redhat::redhat':
            manage_rdo => false,
            repo_hash => {
              'openstack-common-testing' => {
                'baseurl'  => 'http://cbs.centos.org/repos/cloud7-openstack-common-testing/x86_64/os/',
                'descr'    => 'openstack-common-testing',
                'gpgcheck' => 'no',
              },
              'openstack-liberty-testing' => {
                'baseurl'  => 'http://cbs.centos.org/repos/cloud7-openstack-liberty-testing/x86_64/os/',
                'descr'    => 'openstack-liberty-testing',
                'gpgcheck' => 'no',
              },
              'openstack-liberty-trunk' => {
                'baseurl'  => 'http://trunk.rdoproject.org/centos7-liberty/current-passed-ci/',
                'descr'    => 'openstack-liberty-trunk',
                'gpgcheck' => 'no',
              },
            },
          }
          package { 'openstack-selinux': ensure => 'latest' }
        }
        default: {
          fail("Unsupported osfamily (${::osfamily})")
        }
      }

      class { '::mysql::server': }

      # Keystone resources, needed by Gnocchi to run
      class { '::keystone::db::mysql':
        password => 'keystone',
      }
      class { '::keystone':
        verbose             => true,
        debug               => true,
        database_connection => 'mysql://keystone:keystone@127.0.0.1/keystone',
        admin_token         => 'admin_token',
        enabled             => true,
      }
      class { '::keystone::roles::admin':
        email    => 'test@example.tld',
        password => 'a_big_secret',
      }
      class { '::keystone::endpoint':
        public_url => "https://${::fqdn}:5000/",
        admin_url  => "https://${::fqdn}:35357/",
      }
      class { '::gnocchi::db::mysql':
        password => 'a_big_secret',
      }
      class { '::gnocchi::keystone::auth':
        password => 'a_big_secret',
      }
      case $::osfamily {
        'Debian': {
          warning('Gnocchi is not yet packaged on Ubuntu systems.')
        }
        'RedHat': {
          class { '::gnocchi':
            verbose             => true,
            debug               => true,
            database_connection => 'mysql://gnocchi:a_big_secret@127.0.0.1/gnocchi?charset=utf8',
          }
          class { '::gnocchi::api':
            enabled               => true,
            keystone_password     => 'a_big_secret',
            keystone_identity_uri => 'http://127.0.0.1:35357/',
            service_name          => 'httpd',
          }
          class { '::gnocchi::db::sync': }
          class { '::gnocchi::storage': }
          class { '::gnocchi::storage::file': }
          include ::apache
          class { '::gnocchi::wsgi::apache':
            ssl => false,
          }
        }
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    if os[:family].casecmp('RedHat') == 0
      describe port(8041) do
        it { is_expected.to be_listening }
      end
    end

  end
end

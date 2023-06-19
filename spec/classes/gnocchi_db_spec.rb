require 'spec_helper'

describe 'gnocchi::db' do
  shared_examples 'gnocchi::db' do
    context 'with default parameters' do
      it { should contain_gnocchi_config('indexer/url').with(
        :value  => 'sqlite:////var/lib/gnocchi/gnocchi.sqlite',
        :secret => true,
      )}
    end

    context 'with specific parameters' do
      let :params do
        {
          :database_connection => 'mysql+pymysql://gnocchi:gnocchi@localhost/gnocchi'
        }
      end

      it { should contain_gnocchi_config('indexer/url').with(
        :value  => 'mysql+pymysql://gnocchi:gnocchi@localhost/gnocchi',
        :secret => true,
      )}
    end

    context 'with postgresql backend' do
      let :params do
        { :database_connection => 'postgresql://gnocchi:gnocchi@localhost/gnocchi', }
      end

      it { should contain_class('postgresql::lib::python') }
    end

    context 'with MySQL-python library as backend package' do
      let :params do
        {
          :database_connection => 'mysql://gnocchi:gnocchi@localhost/gnocchi',
        }
      end

      it { should contain_class('mysql::bindings') }
      it { should contain_class('mysql::bindings::python') }
    end

    context 'with incorrect database_connection string' do
      let :params do
        {
          :database_connection => 'redis://gnocchi:gnocchi@localhost/gnocchi',
        }
      end

      it { should raise_error(Puppet::Error) }
    end

    context 'with incorrect pymysql database_connection string' do
      let :params do
        {
          :database_connection => 'foo+pymysql://gnocchi:gnocchi@localhost/gnocchi',
        }
      end

      it { should raise_error(Puppet::Error) }
    end
  end

  shared_examples 'gnocchi::db on Debian' do
    context 'using pymysql driver' do
      let :params do
        {
          :database_connection => 'mysql+pymysql://gnocchi:gnocchi@localhost/gnocchi',
        }
      end

      it { should contain_package('gnocchi-backend-package').with(
        :ensure => 'present',
        :name   => platform_params[:pymysql_package_name],
        :tag    => 'openstack'
      )}
    end
  end

  shared_examples 'gnocchi::db on RedHat' do
    context 'using sqlite' do
      it { should contain_package('gnocchi-indexer-sqlalchemy').with(
        :name   => 'openstack-gnocchi-indexer-sqlalchemy',
        :ensure => 'present',
        :tag    => ['openstack', 'gnocchi-package']
      )}
    end

    context 'using pymysql driver' do
      let :params do
        {
          :database_connection => 'mysql+pymysql://gnocchi:gnocchi@localhost/gnocchi',
        }
      end

      it { should_not contain_package('gnocchi-backend-package') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          # puppet-postgresql requires the service_provider fact provided by
          # puppetlabs-postgresql.
          :service_provider => 'systemd'
        }))
      end

      let(:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          {
            :pymysql_package_name => 'python3-pymysql',
          }
        end
      end

      it_behaves_like 'gnocchi::db'
      it_behaves_like "gnocchi::db on #{facts[:os]['family']}"
    end
  end
end

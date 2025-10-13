#
# Unit tests for gnocchi::keystone::auth
#

require 'spec_helper'

describe 'gnocchi::keystone::auth' do
  shared_examples_for 'gnocchi::keystone::auth' do
    context 'with default class parameters' do
      let :params do
        { :password => 'gnocchi_password' }
      end

      it { is_expected.to contain_keystone__resource__service_identity('gnocchi').with(
        :configure_user      => true,
        :configure_user_role => true,
        :configure_endpoint  => true,
        :configure_service   => true,
        :service_name        => 'gnocchi',
        :service_type        => 'metric',
        :service_description => 'OpenStack Metric Service',
        :region              => 'RegionOne',
        :auth_name           => 'gnocchi',
        :password            => 'gnocchi_password',
        :email               => 'gnocchi@localhost',
        :tenant              => 'services',
        :roles               => ['admin', 'service'],
        :system_scope        => 'all',
        :system_roles        => [],
        :public_url          => 'http://127.0.0.1:8041',
        :internal_url        => 'http://127.0.0.1:8041',
        :admin_url           => 'http://127.0.0.1:8041',
      ) }
    end

    context 'when overriding parameters' do
      let :params do
        { :password            => 'gnocchi_password',
          :auth_name           => 'alt_gnocchi',
          :email               => 'alt_gnocchi@alt_localhost',
          :tenant              => 'alt_service',
          :roles               => ['admin'],
          :system_scope        => 'all',
          :system_roles        => ['admin', 'member', 'reader'],
          :configure_endpoint  => false,
          :configure_user      => false,
          :configure_user_role => false,
          :configure_service   => false,
          :service_description => 'Alternative OpenStack Metric Service',
          :service_name        => 'alt_service',
          :service_type        => 'alt_metric',
          :region              => 'RegionTwo',
          :public_url          => 'https://10.10.10.10:80',
          :internal_url        => 'http://10.10.10.11:81',
          :admin_url           => 'http://10.10.10.12:81' }
      end

      it { is_expected.to contain_keystone__resource__service_identity('gnocchi').with(
        :configure_user      => false,
        :configure_user_role => false,
        :configure_endpoint  => false,
        :configure_service   => false,
        :service_name        => 'alt_service',
        :service_type        => 'alt_metric',
        :service_description => 'Alternative OpenStack Metric Service',
        :region              => 'RegionTwo',
        :auth_name           => 'alt_gnocchi',
        :password            => 'gnocchi_password',
        :email               => 'alt_gnocchi@alt_localhost',
        :tenant              => 'alt_service',
        :roles               => ['admin'],
        :system_scope        => 'all',
        :system_roles        => ['admin', 'member', 'reader'],
        :public_url          => 'https://10.10.10.10:80',
        :internal_url        => 'http://10.10.10.11:81',
        :admin_url           => 'http://10.10.10.12:81',
      ) }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'gnocchi::keystone::auth'
    end
  end
end

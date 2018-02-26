require 'spec_helper'

describe 'gnocchi::api' do

  let :pre_condition do
    "class { 'gnocchi': }
     include ::gnocchi::db
     class { '::gnocchi::keystone::authtoken':
       password => 'gnocchi-passw0rd',
     }"
  end

  let :params do
    { :enabled           => true,
      :manage_service    => true,
      :package_ensure    => 'latest',
      :max_limit         => '1000',
    }
  end

  shared_examples_for 'gnocchi-api wsgi' do
    context 'with gnocchi-api in wsgi' do
      before do
        params.merge!({ :service_name => 'httpd' })
      end

      let :pre_condition do
        "include ::apache
         include ::gnocchi::db
         class { 'gnocchi': }
         class { '::gnocchi::keystone::authtoken':
           password => 'gnocchi-passw0rd',
         }"
      end

      it 'installs gnocchi-api package' do
        is_expected.to contain_package('gnocchi-api').with(
          :ensure => 'latest',
          :name   => platform_params[:api_package_name],
          :tag    => ['openstack', 'gnocchi-package'],
        )
      end
    end
  end

  shared_examples_for 'gnocchi-api' do

    it { is_expected.to contain_class('gnocchi::deps') }
    it { is_expected.to contain_class('gnocchi::params') }
    it { is_expected.to contain_class('gnocchi::policy') }

    it 'installs gnocchi-api package' do
      is_expected.to contain_package('gnocchi-api').with(
        :ensure => 'latest',
        :name   => platform_params[:api_package_name],
        :tag    => ['openstack', 'gnocchi-package'],
      )
    end

    it 'configures gnocchi-api' do
      is_expected.to contain_gnocchi_config('api/max_limit').with_value( params[:max_limit] )
      is_expected.to contain_gnocchi_config('api/auth_mode').with_value('keystone')
      is_expected.to contain_gnocchi_config('oslo_middleware/enable_proxy_headers_parsing').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_gnocchi_config('api/middlewares').with_value('<SERVICE DEFAULT>')
    end

    [{:enabled => true}, {:enabled => false}].each do |param_hash|
      context "when service should be #{param_hash[:enabled] ? 'enabled' : 'disabled'}" do
        before do
          params.merge!(param_hash)
        end

        it 'configures gnocchi-api service' do
          is_expected.to contain_service('gnocchi-api').with(
            :ensure     => (params[:manage_service] && params[:enabled]) ? 'running' : 'stopped',
            :name       => platform_params[:api_service_name],
            :enable     => params[:enabled],
            :hasstatus  => true,
            :hasrestart => true,
            :tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
          )
        end
        it { is_expected.to contain_service('gnocchi-api').that_subscribes_to('Anchor[gnocchi::service::begin]')}
        it { is_expected.to contain_service('gnocchi-api').that_notifies('Anchor[gnocchi::service::end]')}
      end
    end

    context 'with sync_db set to true' do
      before do
        params.merge!({
          :sync_db => true})
      end
      it { is_expected.to contain_class('gnocchi::db::sync') }
    end

    context 'with disabled service managing' do
      before do
        params.merge!({
          :manage_service => false,
          :enabled        => false })
      end

      it 'configures gnocchi-api service' do
        is_expected.to contain_service('gnocchi-api').with(
          :ensure     => nil,
          :name       => platform_params[:api_service_name],
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
        )
      end
    end

    context 'when running gnocchi-api in wsgi' do
      before do
        params.merge!({ :service_name   => 'httpd' })
      end

      let :pre_condition do
        "include ::apache
         include ::gnocchi::db
         class { 'gnocchi': }
         class { '::gnocchi::keystone::authtoken':
           password => 'gnocchi-passw0rd',
         }"
      end

      it 'configures gnocchi-api service with Apache' do
        is_expected.to contain_service('gnocchi-api').with(
          :ensure     => 'stopped',
          :name       => platform_params[:api_service_name],
          :enable     => false,
          :tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
        )
      end
    end

    context 'when service_name is not valid' do
      before do
        params.merge!({ :service_name   => 'foobar' })
      end

      let :pre_condition do
        "include ::apache
         include ::gnocchi::db
         class { 'gnocchi': }
         class { '::gnocchi::keystone::authtoken':
           password => 'gnocchi-passw0rd',
         }"
      end

      it_raises 'a Puppet::Error', /Invalid service_name/
    end

    context 'with enable_proxy_headers_parsing' do
      before do
        params.merge!({:enable_proxy_headers_parsing => true })
      end

      it { is_expected.to contain_gnocchi_config('oslo_middleware/enable_proxy_headers_parsing').with_value(true) }
    end

  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          :concat_basedir => '/var/lib/puppet/concat',
        }))
      end

      let(:platform_params) do
        if facts[:operatingsystem] == 'Ubuntu' then
          package_name = 'python-gnocchi'
        else
          package_name = 'gnocchi-api'
        end
        { :api_package_name => package_name,
          :api_service_name => 'gnocchi-api' }
      end

      it_behaves_like 'gnocchi-api wsgi'
      it_behaves_like 'gnocchi-api'
    end
  end

end

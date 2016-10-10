require 'spec_helper'

describe 'gnocchi::api' do

  let :pre_condition do
    "class { 'gnocchi': }
     include ::gnocchi::db"
  end

  let :params do
    { :enabled           => true,
      :manage_service    => true,
      :keystone_password => 'gnocchi-passw0rd',
      :package_ensure    => 'latest',
      :port              => '8041',
      :max_limit         => '1000',
      :host              => '0.0.0.0',
    }
  end

  shared_examples_for 'gnocchi-api' do

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
      is_expected.to contain_gnocchi_config('api/host').with_value( params[:host] )
      is_expected.to contain_gnocchi_config('api/port').with_value( params[:port] )
      is_expected.to contain_gnocchi_config('api/max_limit').with_value( params[:max_limit] )
      is_expected.to contain_gnocchi_config('api/workers').with_value('2')
      is_expected.to contain_gnocchi_config('oslo_middleware/enable_proxy_headers_parsing').with_value('<SERVICE DEFAULT>')
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
            :require    => 'Class[Gnocchi::Db]',
            :tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
          )
        end
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
         class { 'gnocchi': }"
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
         class { 'gnocchi': }"
      end

      it_raises 'a Puppet::Error', /Invalid service_name/
    end

    context "with noauth" do
      before do
        params.merge!({
          :auth_strategy => 'noauth',
        })
      end
      it 'configures pipeline' do
        is_expected.to contain_gnocchi_api_paste_ini('pipeline:main/pipeline').with_value('gnocchi+noauth');
      end
    end

    context "with keystone" do
      before do
        params.merge!({
          :auth_strategy => 'keystone',
        })
      end
      it 'configures pipeline' do
        is_expected.to contain_gnocchi_api_paste_ini('pipeline:main/pipeline').with_value('gnocchi+auth');
      end
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
          :processorcount => 2
        }))
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :api_package_name => 'gnocchi-api',
            :api_service_name => 'gnocchi-api' }
        when 'RedHat'
          { :api_package_name => 'openstack-gnocchi-api',
            :api_service_name => 'openstack-gnocchi-api' }
        end
      end
      it_behaves_like 'gnocchi-api'
    end
  end

end

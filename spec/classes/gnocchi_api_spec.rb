require 'spec_helper'

describe 'gnocchi::api' do

  let :pre_condition do
    "class { 'gnocchi': }
     include gnocchi::db
     class { 'gnocchi::keystone::authtoken':
       password => 'gnocchi-passw0rd',
     }"
  end

  let :params do
    { :enabled        => true,
      :manage_service => true,
      :package_ensure => 'latest',
    }
  end

  shared_examples_for 'gnocchi-api wsgi' do
    context 'with gnocchi-api in wsgi' do
      before do
        params.merge!({ :service_name => 'httpd' })
      end

      let :pre_condition do
        "include apache
         include gnocchi::db
         class { 'gnocchi': }
         class { 'gnocchi::keystone::authtoken':
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
      is_expected.to contain_gnocchi_config('api/max_limit').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_gnocchi_config('api/auth_mode').with_value('keystone')
      is_expected.to contain_gnocchi_config('api/paste_config').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_gnocchi_config('api/operation_timeout').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_gnocchi_config('api/enable_proxy_headers_parsing').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_oslo__middleware('gnocchi_config').with(
        :max_request_body_size => '<SERVICE DEFAULT>',
      )
    end

    [{:enabled => true}, {:enabled => false}].each do |param_hash|
      context "when service should be #{param_hash[:enabled] ? 'enabled' : 'disabled'}" do
        before do
          params.merge!(param_hash)
        end

        it 'configures gnocchi-api service' do
          is_expected.to contain_service('gnocchi-api').with(
            :ensure     => params[:enabled] ? 'running' : 'stopped',
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
          :manage_service => false
        })
      end

      it 'does not configure gnocchi-api service' do
        is_expected.to_not contain_service('gnocchi-api')
      end
    end

    context 'when running gnocchi-api in wsgi' do
      before do
        params.merge!({ :service_name   => 'httpd' })
      end

      let :pre_condition do
        "include apache
         include gnocchi::db
         class { 'gnocchi': }
         class { 'gnocchi::keystone::authtoken':
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
        "include apache
         include gnocchi::db
         class { 'gnocchi': }
         class { 'gnocchi::keystone::authtoken':
           password => 'gnocchi-passw0rd',
         }"
      end

      it_raises 'a Puppet::Error', /Invalid service_name/
    end

    context 'with max_limit' do
      before do
        params.merge!({:max_limit => 1000 })
      end

      it { is_expected.to contain_gnocchi_config('api/max_limit').with_value(1000) }
    end

    context 'with paste_config' do
      before do
        params.merge!({:paste_config => 'api-paste.ini' })
      end

      it { is_expected.to contain_gnocchi_config('api/paste_config').with_value('api-paste.ini') }
    end

    context 'with operation_timeout' do
      before do
        params.merge!({:operation_timeout => 10 })
      end

      it { is_expected.to contain_gnocchi_config('api/operation_timeout').with_value(10) }
    end

    context 'with enable_proxy_headers_parsing' do
      before do
        params.merge!({:enable_proxy_headers_parsing => true })
      end

      it { is_expected.to contain_gnocchi_config('api/enable_proxy_headers_parsing').with_value(true) }
    end

    context 'with max_request_body_size' do
      before do
        params.merge!({:max_request_body_size => '102400' })
      end

      it { is_expected.to contain_oslo__middleware('gnocchi_config').with(
        :max_request_body_size => '102400',
      )}
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
        case facts[:osfamily]
        when 'Debian'
          package_name = 'gnocchi-api'
        when 'RedHat'
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

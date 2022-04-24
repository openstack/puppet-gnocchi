require 'spec_helper'

describe 'gnocchi::statsd' do

  let :params do
    { :enabled        => true,
      :manage_service => true,
      :resource_id    => '07f26121-5777-48ba-8a0b-d70468133dd9',
    }
  end

  shared_examples_for 'gnocchi-statsd' do

    it { is_expected.to contain_class('gnocchi::deps') }
    it { is_expected.to contain_class('gnocchi::params') }

    it 'installs gnocchi-statsd package' do
      is_expected.to contain_package('gnocchi-statsd').with(
        :ensure => 'present',
        :name   => platform_params[:statsd_package_name],
        :tag    => ['openstack', 'gnocchi-package'],
      )
    end

    it 'configures gnocchi statsd' do
      is_expected.to contain_gnocchi_config('statsd/resource_id').with_value('07f26121-5777-48ba-8a0b-d70468133dd9')
      is_expected.to contain_gnocchi_config('statsd/host').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_gnocchi_config('statsd/port').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_gnocchi_config('statsd/flush_delay').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_gnocchi_config('statsd/archive_policy_name').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_gnocchi_config('statsd/creator').with_value('<SERVICE DEFAULT>')
    end

    [{:enabled => true}, {:enabled => false}].each do |param_hash|
      context "when service should be #{param_hash[:enabled] ? 'enabled' : 'disabled'}" do
        before do
          params.merge!(param_hash)
        end

        it 'configures gnocchi-statsd service' do
          is_expected.to contain_service('gnocchi-statsd').with(
            :ensure     => params[:enabled] ? 'running' : 'stopped',
            :name       => platform_params[:statsd_service_name],
            :enable     => params[:enabled],
            :hasstatus  => true,
            :hasrestart => true,
            :tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
          )
        end
      end
    end

    context 'with disabled service managing' do
      before do
        params.merge!({
          :manage_service => false
        })
      end

      it 'does not configure gnocchi-statsd service' do
        is_expected.to_not contain_service('gnocchi-statsd')
      end
    end

    context 'whth host and port' do
      before do
        params.merge!({
          :host => '192.0.2.1',
          :port => 8125,
        })
      end

      it 'configures the parameter' do
        is_expected.to contain_gnocchi_config('statsd/host').with_value('192.0.2.1')
        is_expected.to contain_gnocchi_config('statsd/port').with_value(8125)
      end
    end

    context 'with flush_delay' do
      before do
        params.merge!({ :flush_delay => 10 })
      end

      it 'configures the parameter' do
        is_expected.to contain_gnocchi_config('statsd/flush_delay').with_value(10)
      end
    end

    context 'with archive_policy_name' do
      before do
        params.merge!({ :archive_policy_name => 'high' })
      end

      it 'configures the parameter' do
        is_expected.to contain_gnocchi_config('statsd/archive_policy_name').with_value('high')
      end
    end

    context 'with creator' do
      before do
        params.merge!({ :creator => 'creator' })
      end

      it 'configures the parameter' do
        is_expected.to contain_gnocchi_config('statsd/creator').with_value('creator')
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        { :statsd_package_name => 'gnocchi-statsd',
          :statsd_service_name => 'gnocchi-statsd' }
      end
      it_behaves_like 'gnocchi-statsd'
    end
  end

end

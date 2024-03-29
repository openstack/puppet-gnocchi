require 'spec_helper'

describe 'gnocchi::metricd' do

  let :params do { }
  end

  shared_examples_for 'gnocchi-metricd' do

    it { is_expected.to contain_class('gnocchi::deps') }
    it { is_expected.to contain_class('gnocchi::params') }

    it 'installs gnocchi-metricd package' do
      is_expected.to contain_package('gnocchi-metricd').with(
        :ensure => 'present',
        :name   => platform_params[:metricd_package_name],
        :tag    => ['openstack', 'gnocchi-package'],
      )
    end

    it 'configures the default value' do
      is_expected.to contain_gnocchi_config('metricd/workers').with_value(4)
      is_expected.to contain_gnocchi_config('metricd/metric_processing_delay').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_gnocchi_config('metricd/greedy').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_gnocchi_config('metricd/metric_reporting_delay').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_gnocchi_config('metricd/metric_cleanup_delay').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_gnocchi_config('metricd/processing_replicas').with_value('<SERVICE DEFAULT>')
    end

    [{:enabled => true}, {:enabled => false}].each do |param_hash|
      context "when service should be #{param_hash[:enabled] ? 'enabled' : 'disabled'}" do
        before do
          params.merge!(param_hash)
        end

        it 'configures gnocchi-metricd service' do
          is_expected.to contain_service('gnocchi-metricd').with(
            :ensure     => params[:enabled] ? 'running' : 'stopped',
            :name       => platform_params[:metricd_service_name],
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

      it 'does not configure gnocchi-metricd service' do
        is_expected.to_not contain_service('gnocchi-metricd')
      end
    end

    context 'with parameters set' do
      before do
        params.merge!({
          :workers                 => 2,
          :metric_processing_delay => 60,
          :greedy                  => true,
          :metric_reporting_delay  => 120,
          :metric_cleanup_delay    => 300,
          :processing_replicas     => 3,
        })
      end

      it 'configures the overridden value' do
        is_expected.to contain_gnocchi_config('metricd/workers').with_value(2)
        is_expected.to contain_gnocchi_config('metricd/metric_processing_delay').with_value(60)
        is_expected.to contain_gnocchi_config('metricd/greedy').with_value(true)
        is_expected.to contain_gnocchi_config('metricd/metric_reporting_delay').with_value(120)
        is_expected.to contain_gnocchi_config('metricd/metric_cleanup_delay').with_value(300)
        is_expected.to contain_gnocchi_config('metricd/processing_replicas').with_value(3)
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({ :os_workers => 4 }))
      end

      let(:platform_params) do
        { :metricd_package_name => 'gnocchi-metricd',
          :metricd_service_name => 'gnocchi-metricd' }
      end
      it_behaves_like 'gnocchi-metricd'
    end
  end

end

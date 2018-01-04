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
          :manage_service => false,
          :enabled        => false })
      end

      it 'configures gnocchi-metricd service' do
        is_expected.to contain_service('gnocchi-metricd').with(
          :ensure     => nil,
          :name       => platform_params[:metricd_service_name],
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
        )
      end
    end

    context 'with workers set' do
      before do
        params.merge!({
          :workers => 2 })
      end
      it 'configures gnocchi metricd worker value' do
        is_expected.to contain_gnocchi_config('metricd/workers').with_value('2')
      end
    end

    context 'with metric delay set' do
      before do
        params.merge!({
          :metric_processing_delay => 15 })
      end
      it 'configures gnocchi metricd processing delay value' do
        is_expected.to contain_gnocchi_config('metricd/metric_processing_delay').with_value('15')
      end
    end

    context 'with cleanup_delay set' do
      before do
        params.merge!({
          :cleanup_delay => 30 })
      end
      it 'configures gnocchi metricd cleanup_delay value' do
        is_expected.to contain_gnocchi_config('metricd/metric_cleanup_delay').with_value('30')
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
        { :metricd_package_name => 'gnocchi-metricd',
          :metricd_service_name => 'gnocchi-metricd' }
      end
      it_behaves_like 'gnocchi-metricd'
    end
  end

end

require 'spec_helper'

describe 'gnocchi::storage' do

  let :params do
    { :package_ensure => 'latest' }
  end

  shared_examples_for 'gnocchi-storage' do

    it { is_expected.to contain_class('gnocchi::deps') }
    it { is_expected.to contain_class('gnocchi::params') }

    context 'with coordination' do
      before do
        params.merge!({
          :coordination_url        => 'redis://localhost:6379',
          :metric_processing_delay => 30,
        })
      end

      it 'configures backend_url' do
        is_expected.to contain_gnocchi_config('storage/coordination_url').with_value('redis://localhost:6379')
        is_expected.to contain_gnocchi_config('storage/metric_processing_delay').with_value(30)
      end

      it 'installs python-redis package' do
         is_expected.to contain_package(platform_params[:redis_package_name]).with(
           :name => platform_params[:redis_package_name],
           :tag  => 'openstack'
         )
      end
    end
  end

  shared_examples_for 'gnocchi-storage ubuntu' do
    context 'with coordination set on ubuntu' do
      before do
        params.merge!({
          :coordination_url        => 'redis://localhost:6379',
          :metric_processing_delay => 30,
        })
      end

      it 'installs python3-redis package' do
        is_expected.to contain_package('python3-redis').with(
          :name => 'python3-redis',
          :tag  => 'openstack'
        )
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
         case facts[:osfamily]
         when 'Debian'
           { :redis_package_name     => 'python-redis' }
         when 'RedHat'
           { :redis_package_name     => 'python-redis' }
         end
      end

      if facts[:operatingsystem] == 'Ubuntu' then
        it_behaves_like 'gnocchi-storage ubuntu'
      end

      it_behaves_like 'gnocchi-storage'
    end
  end

end

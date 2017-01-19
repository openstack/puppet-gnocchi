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
        params.merge!({ :coordination_url => 'redis://localhost:6379' })
      end

      it 'configures backend_url' do
        is_expected.to contain_gnocchi_config('storage/coordination_url').with_value('redis://localhost:6379')
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

      it_behaves_like 'gnocchi-storage'
    end
  end

end

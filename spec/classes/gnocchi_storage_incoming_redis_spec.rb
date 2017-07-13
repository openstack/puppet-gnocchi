#
# Unit tests for gnocchi::storage::incoming::redis
#

require 'spec_helper'

describe 'gnocchi::storage::incoming::redis' do

  let :params do
    { :redis_url => 'http://localhost:6378' }
  end

  shared_examples_for 'gnocchi storage redis' do

    it { is_expected.to contain_class('gnocchi::deps') }

    context 'with redis' do
      it 'configures gnocchi incoming driver with redis' do
        is_expected.to contain_gnocchi_config('incoming/driver').with_value('redis')
        is_expected.to contain_gnocchi_config('incoming/redis_url').with_value('http://localhost:6378')
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

      it_behaves_like 'gnocchi storage redis'
    end
  end

end

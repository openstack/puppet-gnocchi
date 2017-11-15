#
# Unit tests for gnocchi::storage::s3
#
require 'spec_helper'

describe 'gnocchi::storage::s3' do

  let :params do
    {
      :s3_endpoint_url => 'https://s3-eu-west-1.amazonaws.com',
      :s3_region_name  => 'eu-west-1',
      :s3_access_key_id => 'xyz',
      :s3_secret_access_key  => 'secret-xyz',
    }
  end

  shared_examples 'gnocchi storage s3' do

    context 'with default parameters' do
      it 'configures gnocchi-api with default parameters' do
        is_expected.to contain_gnocchi_config('storage/driver').with_value('s3')
        is_expected.to contain_gnocchi_config('storage/s3_endpoint_url').with_value('https://s3-eu-west-1.amazonaws.com')
        is_expected.to contain_gnocchi_config('storage/s3_region_name').with_value('eu-west-1')
        is_expected.to contain_gnocchi_config('storage/s3_access_key_id').with_value('xyz')
        is_expected.to contain_gnocchi_config('storage/s3_secret_access_key').with_value('secret-xyz')
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
      it_behaves_like 'gnocchi storage s3'
    end
  end
end

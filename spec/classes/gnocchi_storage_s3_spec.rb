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
        is_expected.to contain_gnocchi_config('storage/s3_secret_access_key').with_value('secret-xyz').with_secret(true)
      end

      it 'installs python-boto3 package' do
        is_expected.to contain_package('python-boto3').with(
          :ensure => 'installed',
          :name   => platform_params[:boto3_package_name],
          :tag    => ['openstack', 'gnocchi-package'],
        )
      end
    end

    context 'with manage_boto3 to false' do
      before do
        params.merge!( :manage_boto3 => false )
      end

      it { is_expected.not_to contain_package('python-boto3') }
    end

    context 'with package_ensure' do
      before do
        params.merge!( :package_ensure => 'latest' )
      end

      it 'installs python-boto3 package' do
        is_expected.to contain_package('python-boto3').with(
          :ensure => 'latest',
          :name   => platform_params[:boto3_package_name],
          :tag    => ['openstack', 'gnocchi-package'],
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
          { :boto3_package_name => 'python3-boto3' }
        when 'RedHat'
          { :boto3_package_name => 'python3-boto3' }
        end
      end

      it_behaves_like 'gnocchi storage s3'
    end
  end
end

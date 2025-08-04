#
# Unit tests for gnocchi::storage::swift
#
require 'spec_helper'

describe 'gnocchi::storage::swift' do

  let :params do
    {}
  end

  shared_examples 'gnocchi storage swift' do

    context 'with default parameters' do
      it 'configures gnocchi-api with default parameters' do
        is_expected.to contain_gnocchi_config('storage/driver').with_value('swift')
        is_expected.to contain_gnocchi_config('storage/swift_user').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_gnocchi_config('storage/swift_key').with_value('<SERVICE DEFAULT>').with_secret(true)
        is_expected.to contain_gnocchi_config('storage/swift_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_gnocchi_config('storage/swift_authurl').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_gnocchi_config('storage/swift_project_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_gnocchi_config('storage/swift_user_domain_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_gnocchi_config('storage/swift_project_domain_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_gnocchi_config('storage/swift_region').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_gnocchi_config('storage/swift_auth_version').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_gnocchi_config('storage/swift_endpoint_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_gnocchi_config('storage/swift_service_type').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_gnocchi_config('storage/swift_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_gnocchi_config('storage/swift_container_prefix').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with specific parameters' do
      before do
        params.merge!({
          :swift_user                => 'swift2',
          :swift_key                 => 'admin',
          :swift_url                 => 'http://localhost:8080',
          :swift_authurl             => 'http://localhost:5000',
          :swift_project_name        => 'service',
          :swift_user_domain_name    => 'Default',
          :swift_project_domain_name => 'Default',
          :swift_region              => 'regionOne',
          :swift_auth_version        => 2,
          :swift_endpoint_type       => 'publicURL',
          :swift_service_type        => 'object-store',
          :swift_timeout             => 0,
          :swift_container_prefix    => 'gnocchi',
        })
      end

      it 'configures gnocchi-api with given endpoint type' do
        is_expected.to contain_gnocchi_config('storage/driver').with_value('swift')
        is_expected.to contain_gnocchi_config('storage/swift_user').with_value('swift2')
        is_expected.to contain_gnocchi_config('storage/swift_key').with_value('admin').with_secret(true)
        is_expected.to contain_gnocchi_config('storage/swift_url').with_value('http://localhost:8080')
        is_expected.to contain_gnocchi_config('storage/swift_authurl').with_value('http://localhost:5000')
        is_expected.to contain_gnocchi_config('storage/swift_project_name').with_value('service')
        is_expected.to contain_gnocchi_config('storage/swift_user_domain_name').with_value('Default')
        is_expected.to contain_gnocchi_config('storage/swift_project_domain_name').with_value('Default')
        is_expected.to contain_gnocchi_config('storage/swift_region').with_value('regionOne')
        is_expected.to contain_gnocchi_config('storage/swift_auth_version').with_value(2)
        is_expected.to contain_gnocchi_config('storage/swift_endpoint_type').with_value('publicURL')
        is_expected.to contain_gnocchi_config('storage/swift_service_type').with_value('object-store')
        is_expected.to contain_gnocchi_config('storage/swift_timeout').with_value(0)
        is_expected.to contain_gnocchi_config('storage/swift_container_prefix').with_value('gnocchi')
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

      it_behaves_like 'gnocchi storage swift'
    end
  end
end

require 'spec_helper'

describe 'gnocchi::client' do
  shared_examples 'gnocchi::client' do
    it { is_expected.to contain_class('gnocchi::deps') }
    it { is_expected.to contain_class('gnocchi::params') }

    it { should contain_package('python-gnocchiclient').with(
      :ensure => 'present',
      :name   => platform_params[:client_package_name],
      :tag    => 'openstack',
    )}
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :client_package_name => 'python3-gnocchiclient' }
        when 'RedHat'
          { :client_package_name => 'python-gnocchiclient' }
        end
      end

      it_behaves_like 'gnocchi::client'
    end
  end
end

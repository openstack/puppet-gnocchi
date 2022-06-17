require 'spec_helper'

describe 'gnocchi' do

  shared_examples 'gnocchi' do

    context 'with default parameters' do
      let :params do
        { :purge_config => false  }
      end

      it 'contains the deps class' do
        is_expected.to contain_class('gnocchi::deps')
      end

      it 'installs packages' do
        is_expected.to contain_package('gnocchi').with(
          :name   => platform_params[:gnocchi_common_package],
          :ensure => 'present',
          :tag    => ['openstack', 'gnocchi-package']
        )
      end

      it 'passes purge to resource' do
        is_expected.to contain_resources('gnocchi_config').with({
          :purge => false
        })
      end

      it 'does not configure coordination_url' do
        is_expected.to contain_gnocchi_config('DEFAULT/coordination_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_oslo__coordination('gnocchi_config').with(
          :backend_url   => '<SERVICE DEFAULT>',
          :manage_config => false,
        )
      end
    end

    context 'with overridden parameters' do
      let :params do
        { :purge_config     => true,
          :coordination_url => 'redis://localhost:6379', }
      end

      it 'purges gnocchi config' do
        is_expected.to contain_resources('gnocchi_config').with({
          :purge => true
        })
      end

      it 'configures coordination' do
        is_expected.to contain_gnocchi_config('DEFAULT/coordination_url').with_value('redis://localhost:6379')
        is_expected.to contain_oslo__coordination('gnocchi_config').with(
          :backend_url   => 'redis://localhost:6379',
          :manage_config => false,
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
          { :gnocchi_common_package => 'gnocchi-common' }
        when 'RedHat'
          { :gnocchi_common_package => 'gnocchi-common' }
        end
      end
      it_behaves_like 'gnocchi'
    end
  end

end

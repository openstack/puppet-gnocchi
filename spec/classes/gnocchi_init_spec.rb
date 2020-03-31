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
        is_expected.not_to contain_gnocchi_config('DEFAUTL/coordination_url')
        is_expected.not_to contain_package('python-redis')
      end
    end

    context 'with overriden parameters' do
      let :params do
        { :purge_config     => true,
          :coordination_url => 'redis://localhost:6379', }
      end

      it 'purges gnocchi config' do
        is_expected.to contain_resources('gnocchi_config').with({
          :purge => true
        })
      end

      it 'cnfigures coordination' do
        is_expected.to contain_gnocchi_config('DEFAULT/coordination_url').with_value('redis://localhost:6379')
        is_expected.to contain_package('python-redis').with(
          :name   => platform_params[:redis_package_name],
          :ensure => 'present',
          :tag    => 'openstack'
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
          { :gnocchi_common_package => 'gnocchi-common',
            :redis_package_name     => 'python3-redis'
          }
        when 'RedHat'
          if facts[:operatingsystem] == 'Fedora'
            { :gnocchi_common_package => 'gnocchi-common',
              :redis_package_name     => 'python3-redis'
            }
          else
            if facts[:operatingsystemmajrelease] > '7'
              { :gnocchi_common_package => 'gnocchi-common',
                :redis_package_name     => 'python3-redis'
              }
            else
              { :gnocchi_common_package => 'gnocchi-common',
                :redis_package_name     => 'python-redis'
              }
            end
          end
        end
      end
      it_behaves_like 'gnocchi'
    end
  end

end

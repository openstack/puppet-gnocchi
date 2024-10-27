require 'spec_helper'

describe 'gnocchi::db' do
  shared_examples 'gnocchi::db' do
    context 'with default parameters' do
      it { should contain_class('gnocchi::deps') }

      it { should contain_oslo__db('gnocchi_config').with(
        :db_max_retries          => '<SERVICE DEFAULT>',
        :connection_recycle_time => '<SERVICE DEFAULT>',
        :max_pool_size           => '<SERVICE DEFAULT>',
        :max_retries             => '<SERVICE DEFAULT>',
        :retry_interval          => '<SERVICE DEFAULT>',
        :max_overflow            => '<SERVICE DEFAULT>',
        :pool_timeout            => '<SERVICE DEFAULT>',
        :mysql_enable_ndb        => '<SERVICE DEFAULT>',
        :manage_backend_package  => false,
        :manage_config           => true,
      )}

      it { should contain_oslo__db('gnocchi_config_connection').with(
        :config                 => 'gnocchi_config',
        :connection             => 'sqlite:////var/lib/gnocchi/gnocchi.sqlite',
        :manage_backend_package => true,
        :manage_config          => false,
      )}

      it { should contain_gnocchi_config('indexer/url').with(
        :value  => 'sqlite:////var/lib/gnocchi/gnocchi.sqlite',
        :secret => true,
      )}
    end

    context 'with specific parameters' do
      let :params do
        {
          :database_db_max_retries          => '-1',
          :database_connection              => 'mysql+pymysql://gnocchi:gnocchi@localhost/gnocchi',
          :slave_connection                 => 'mysql+pymysql://gnocchi:gnocchi@localhost2/gnocchi',
          :database_connection_recycle_time => '3601',
          :database_max_pool_size           => '11',
          :database_max_retries             => '11',
          :database_retry_interval          => '11',
          :database_max_overflow            => '21',
          :database_pool_timeout            => '21',
          :mysql_enable_ndb                 => true,
        }
      end

      it { should contain_class('gnocchi::deps') }

      it { should contain_oslo__db('gnocchi_config').with(
        :db_max_retries          => '-1',
        :slave_connection        => 'mysql+pymysql://gnocchi:gnocchi@localhost2/gnocchi',
        :connection_recycle_time => '3601',
        :max_pool_size           => '11',
        :max_retries             => '11',
        :retry_interval          => '11',
        :max_overflow            => '21',
        :pool_timeout            => '21',
        :mysql_enable_ndb        => true,
        :manage_backend_package  => false,
        :manage_config           => true,
      )}
      it { should contain_oslo__db('gnocchi_config_connection').with(
        :config                 => 'gnocchi_config',
        :connection             => 'mysql+pymysql://gnocchi:gnocchi@localhost/gnocchi',
        :manage_backend_package => true,
        :manage_config          => false,
      )}
      it { should contain_gnocchi_config('indexer/url').with(
        :value  => 'mysql+pymysql://gnocchi:gnocchi@localhost/gnocchi',
        :secret => true,
      )}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'gnocchi::db'
    end
  end
end

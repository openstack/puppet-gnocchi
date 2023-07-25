require 'spec_helper'

describe 'gnocchi::db' do
  shared_examples 'gnocchi::db' do
    context 'with default parameters' do
      it { should contain_class('gnocchi::deps') }

      it { should contain_oslo__db('gnocchi_config').with(
        :connection    => 'sqlite:////var/lib/gnocchi/gnocchi.sqlite',
        :manage_config => false,
      )}
      it { should contain_gnocchi_config('indexer/url').with(
        :value  => 'sqlite:////var/lib/gnocchi/gnocchi.sqlite',
        :secret => true,
      )}
    end

    context 'with specific parameters' do
      let :params do
        {
          :database_connection => 'mysql+pymysql://gnocchi:gnocchi@localhost/gnocchi'
        }
      end

      it { should contain_class('gnocchi::deps') }

      it { should contain_oslo__db('gnocchi_config').with(
        :connection    => 'mysql+pymysql://gnocchi:gnocchi@localhost/gnocchi',
        :manage_config => false,
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

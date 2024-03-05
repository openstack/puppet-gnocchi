require 'spec_helper'

describe 'gnocchi::db::sync' do

  shared_examples_for 'gnocchi-dbsync' do

    it { is_expected.to contain_class('gnocchi::deps') }

    it 'runs gnocchi-manage db_sync' do
      is_expected.to contain_exec('gnocchi-db-sync').with(
        :command     => 'gnocchi-upgrade ',
        :path        => '/usr/bin',
        :user        => 'gnocchi',
        :refreshonly => 'true',
        :try_sleep   => 5,
        :tries       => 10,
        :timeout     => 300,
        :logoutput   => 'on_failure',
        :subscribe   => ['Anchor[gnocchi::install::end]',
                         'Anchor[gnocchi::config::end]',
                         'Anchor[gnocchi::dbsync::begin]'],
        :notify      => 'Anchor[gnocchi::dbsync::end]',
        :tag         => 'openstack-db',
      )
    end
    describe "overriding params" do
        let :params do
            {
              :extra_opts      => '--skip-storage',
              :db_sync_timeout => 750,
            }
        end
        it { is_expected.to contain_exec('gnocchi-db-sync').with(
            :command     => 'gnocchi-upgrade --skip-storage',
            :path        => '/usr/bin',
            :user        => 'gnocchi',
            :refreshonly => 'true',
            :try_sleep   => 5,
            :tries       => 10,
            :timeout     => 750,
            :logoutput   => 'on_failure',
            :subscribe   => ['Anchor[gnocchi::install::end]',
                             'Anchor[gnocchi::config::end]',
                             'Anchor[gnocchi::dbsync::begin]'],
            :notify      => 'Anchor[gnocchi::dbsync::end]',
            :tag         => 'openstack-db',
        )
       }
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'gnocchi-dbsync'
    end
  end

end

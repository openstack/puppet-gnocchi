#
# Unit tests for gnocchi::storage::ceph
#
require 'spec_helper'

describe 'gnocchi::storage::ceph' do

  let :params do
    {
      :ceph_username => 'joe',
      :ceph_keyring  => 'client.admin',
      :manage_cradox => false,
      :manage_rados  => true,
    }
  end

  shared_examples 'gnocchi storage ceph' do

    context 'with default parameters' do
      it 'configures gnocchi-api with default parameters' do
        is_expected.to contain_gnocchi_config('storage/driver').with_value('ceph')
        is_expected.to contain_gnocchi_config('storage/ceph_username').with_value('joe')
        is_expected.to contain_gnocchi_config('storage/ceph_keyring').with_value('client.admin')
        is_expected.to contain_gnocchi_config('storage/ceph_pool').with_value('gnocchi')
        is_expected.to contain_gnocchi_config('storage/ceph_conffile').with_value('/etc/ceph/ceph.conf')
      end
    end

    context 'with ceph_secret parameter' do
      before do
        params.merge!({
          :ceph_secret => 'secrete'})
      end
      it { is_expected.to contain_gnocchi_config('storage/ceph_secret').with_value('secrete') }
    end

    context 'without required parameters' do
      before { params.delete(:ceph_keyring) }
      it { expect { is_expected.to raise_error(Puppet::Error) } }
    end

    context 'with both required parameters set to false' do
      before do
        params.merge!({
          :ceph_secret  => false,
          :ceph_keyring => false,
        })
      end
      it { expect { is_expected.to raise_error(Puppet::Error) } }
    end

    context 'with manage_rados to true' do
      before do
        params.merge!({
          :manage_cradox => false,
          :manage_rados  => true,
        })
      end

      it { is_expected.not_to contain_package('python-cradox') }
      it { is_expected.to contain_package('python-rados').with(:ensure => 'present') }

    end

    context 'with manage_cradox and manage_rados to true' do
      before do
        params.merge!({
          :manage_cradox => true,
          :manage_rados  => true,
        })
      end

      it { is_expected.to raise_error(Puppet::Error, /gnocchi::storage::ceph::manage_rados and gnocchi::storage::ceph::manage_cradox both cannot be set to true./) }

    end
  end

  shared_examples 'gnocchi storage ceph cradox redhat' do
    context 'with manage_cradox to true' do
      before do
        params.merge!({
          :manage_cradox => true,
          :manage_rados  => false,
        })
      end

      it { is_expected.to contain_package('python-cradox').with(:ensure => 'present') }
      it { is_expected.not_to contain_package('python-rados') }

    end
  end

  shared_examples 'gnocchi storage ceph cradox debian' do
    context 'with manage_cradox to true' do
      before do
        params.merge!({
          :manage_cradox => true,
          :manage_rados  => false,
        })
      end

      it { is_expected.to raise_error(Puppet::Error, /gnocchi::storage::ceph::manage_cradox set to true on debian family will fail due to no package being available./) }

    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      case facts[:osfamily]
      when 'Debian'
          it_behaves_like 'gnocchi storage ceph cradox debian'
      when 'RedHat'
          it_behaves_like 'gnocchi storage ceph cradox redhat'
      end

      it_behaves_like 'gnocchi storage ceph'
    end
  end
end

#
# Unit tests for gnocchi::storage::incoming::file
#

require 'spec_helper'

describe 'gnocchi::storage::incoming::file' do

  let :params do
    {}
  end

  shared_examples_for 'gnocchi storage file' do

    context 'with file' do
      it 'configures gnocchi incoming driver with file' do
        is_expected.to contain_class('gnocchi::deps')
        is_expected.to contain_gnocchi_config('incoming/driver').with_value('file')
        is_expected.to contain_gnocchi_config('incoming/file_basepath').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with file_basepath' do
      let :params do
        { :file_basepath => '/var/lib/gnocchi' }
      end

      it 'configures gnocchi incoming driver with file' do
        is_expected.to contain_gnocchi_config('incoming/driver').with_value('file')
        is_expected.to contain_gnocchi_config('incoming/file_basepath').with_value('/var/lib/gnocchi')
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

      it_behaves_like 'gnocchi storage file'
    end
  end

end

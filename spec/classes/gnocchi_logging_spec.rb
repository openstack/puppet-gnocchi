require 'spec_helper'

describe 'gnocchi::logging' do

  let :params do
    {
    }
  end

  let :log_params do
    {
     :use_syslog => true,
     :use_json => true,
     :use_journal => true,
     :use_stderr => false,
     :log_facility => 'LOG_FOO',
     :log_dir => '/var/log',
     :debug => true,
    }
  end

  shared_examples_for 'gnocchi-logging' do

    context 'with basic logging options and default settings' do
      it_configures  'basic default logging settings'
    end

    context 'with basic logging options and non-default settings' do
      before { params.merge!( log_params ) }
      it_configures 'basic non-default logging settings'
    end

  end

  shared_examples 'basic default logging settings' do
    it 'configures gnocchi logging settings with default values' do
      is_expected.to contain_oslo__log('gnocchi_config').with(
        :use_syslog          => '<SERVICE DEFAULT>',
        :use_json            => '<SERVICE DEFAULT>',
        :use_journal         => '<SERVICE DEFAULT>',
        :use_stderr          => '<SERVICE DEFAULT>',
        :syslog_log_facility => '<SERVICE DEFAULT>',
        :log_dir             => '/var/log/gnocchi',
        :debug               => '<SERVICE DEFAULT>',
      )
    end
  end

  shared_examples 'basic non-default logging settings' do
    it 'configures gnocchi logging settings with non-default values' do
      is_expected.to contain_oslo__log('gnocchi_config').with(
        :use_syslog          => true,
        :use_json            => true,
        :use_journal         => true,
        :use_stderr          => false,
        :syslog_log_facility => 'LOG_FOO',
        :log_dir             => '/var/log',
        :debug               => true,
      )
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'gnocchi-logging'
    end
  end
end

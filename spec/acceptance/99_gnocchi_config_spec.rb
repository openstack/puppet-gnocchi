require 'spec_helper_acceptance'

describe 'basic gnocchi_config resource' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      File <||> -> Gnocchi_config <||>
      File <||> -> Gnocchi_api_paste_ini <||>

      file { '/etc/gnocchi' :
        ensure => directory,
      }
      file { '/etc/gnocchi/gnocchi.conf' :
        ensure => file,
      }
      file { '/etc/gnocchi/api-paste.ini' :
        ensure => file,
      }

      gnocchi_config { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      gnocchi_config { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      gnocchi_config { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      gnocchi_config { 'DEFAULT/thisshouldexist3' :
        value => ['foo', 'bar'],
      }

      gnocchi_config { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      gnocchi_api_paste_ini { 'DEFAULT/thisshouldexist' :
        value => 'foo',
      }

      gnocchi_api_paste_ini { 'DEFAULT/thisshouldnotexist' :
        value => '<SERVICE DEFAULT>',
      }

      gnocchi_api_paste_ini { 'DEFAULT/thisshouldexist2' :
        value             => '<SERVICE DEFAULT>',
        ensure_absent_val => 'toto',
      }

      gnocchi_api_paste_ini { 'DEFAULT/thisshouldnotexist2' :
        value             => 'toto',
        ensure_absent_val => 'toto',
      }

      gnocchi_api_paste_ini { 'DEFAULT/thisshouldexist3' :
        value             => 'foo',
        key_val_separator => ':'
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/etc/gnocchi/gnocchi.conf') do
      it { is_expected.to exist }
      it { is_expected.to contain('thisshouldexist=foo') }
      it { is_expected.to contain('thisshouldexist2=<SERVICE DEFAULT>') }
      it { is_expected.to contain('thisshouldexist3=foo') }
      it { is_expected.to contain('thisshouldexist3=bar') }

      describe '#content' do
        subject { super().content }
        it { is_expected.to_not match /thisshouldnotexist/ }
      end
    end

    describe file('/etc/gnocchi/api-paste.ini') do
      it { is_expected.to exist }
      it { is_expected.to contain('thisshouldexist=foo') }
      it { is_expected.to contain('thisshouldexist2=<SERVICE DEFAULT>') }
      it { is_expected.to contain('thisshouldexist3:foo') }

      describe '#content' do
        subject { super().content }
        it { is_expected.to_not match /thisshouldnotexist/ }
      end
    end
  end
end

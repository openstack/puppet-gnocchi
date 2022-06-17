require 'spec_helper'

describe 'gnocchi::wsgi::apache' do

  shared_examples_for 'apache serving gnocchi with mod_wsgi' do
    context 'with default parameters' do
      it { is_expected.to contain_class('gnocchi::params') }
      it { is_expected.to contain_openstacklib__wsgi__apache('gnocchi_wsgi').with(
        :bind_port                   => 8041,
        :group                       => 'gnocchi',
        :path                        => '/',
        :servername                  => facts[:fqdn],
        :ssl                         => false,
        :threads                     => 1,
        :user                        => 'gnocchi',
        :workers                     => facts[:os_workers],
        :wsgi_daemon_process         => 'gnocchi',
        :wsgi_process_group          => 'gnocchi',
        :wsgi_script_dir             => platform_params[:wsgi_script_path],
        :wsgi_script_file            => 'app',
        :wsgi_script_source          => platform_params[:wsgi_script_source],
        :custom_wsgi_process_options => {},
        :access_log_file             => false,
        :access_log_format           => false,
      )}
    end

    context 'when overriding parameters using different ports' do
      let :params do
        {
          :servername                => 'dummy.host',
          :bind_host                 => '10.42.51.1',
          :port                      => 12345,
          :ssl                       => true,
          :workers                   => 8,
          :wsgi_process_display_name => 'gnocchi',
          :threads                   => 2,
          :custom_wsgi_process_options => {
            'python_path' => '/my/python/path',
          },
          :access_log_file           => '/var/log/httpd/access_log',
          :access_log_format         => 'some format',
          :error_log_file            => '/var/log/httpd/error_log',
          :vhost_custom_fragment     => 'Timeout 99'
        }
      end

      it { is_expected.to contain_class('gnocchi::params') }
      it { is_expected.to contain_openstacklib__wsgi__apache('gnocchi_wsgi').with(
        :bind_host                 => '10.42.51.1',
        :bind_port                 => 12345,
        :group                     => 'gnocchi',
        :path                      => '/',
        :servername                => 'dummy.host',
        :ssl                       => true,
        :threads                   => 2,
        :user                      => 'gnocchi',
        :vhost_custom_fragment     => 'Timeout 99',
        :workers                   => 8,
        :wsgi_daemon_process       => 'gnocchi',
        :wsgi_process_display_name => 'gnocchi',
        :wsgi_process_group        => 'gnocchi',
        :wsgi_script_dir           => platform_params[:wsgi_script_path],
        :wsgi_script_file          => 'app',
        :wsgi_script_source        => platform_params[:wsgi_script_source],
        :custom_wsgi_process_options => {
          'python_path' => '/my/python/path',
        },
        :access_log_file           => '/var/log/httpd/access_log',
        :access_log_format         => 'some format',
        :error_log_file            => '/var/log/httpd/error_log'
      )}
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          :os_workers     => 4,
          :concat_basedir => '/var/lib/puppet/concat',
          :fqdn           => 'some.host.tld',
        }))
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          {
            :wsgi_script_path   => '/usr/lib/cgi-bin/gnocchi',
            :wsgi_script_source => '/usr/bin/gnocchi-api'
          }
        when 'RedHat'
          {
            :wsgi_script_path   => '/var/www/cgi-bin/gnocchi',
            :wsgi_script_source => '/usr/bin/gnocchi-api'
          }
        end
      end

      it_behaves_like 'apache serving gnocchi with mod_wsgi'
    end
  end
end

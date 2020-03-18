require 'spec_helper'

describe 'gnocchi::storage' do

  shared_examples_for 'gnocchi-storage' do
    # Nothong to test
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
           { :redis_package_name => 'python3-redis' }
         when 'RedHat'
           { :redis_package_name => 'python-redis' }
         end
      end

      it_behaves_like 'gnocchi-storage'
    end
  end

end

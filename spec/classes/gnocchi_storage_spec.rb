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

      it_behaves_like 'gnocchi-storage'
    end
  end

end

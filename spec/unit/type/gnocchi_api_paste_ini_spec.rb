require 'puppet'
require 'puppet/type/gnocchi_api_paste_ini'

describe 'Puppet::Type.type(:gnocchi_api_paste_ini)' do
  before :each do
    @gnocchi_api_paste_ini = Puppet::Type.type(:gnocchi_api_paste_ini).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should accept a valid value' do
    @gnocchi_api_paste_ini[:value] = 'bar'
    expect(@gnocchi_api_paste_ini[:value]).to eq('bar')
  end

  it 'should autorequire the anchor that install the file' do
    catalog = Puppet::Resource::Catalog.new
    anchor = Puppet::Type.type(:anchor).new(:name => 'gnocchi::install::end')
    catalog.add_resource anchor, @gnocchi_api_paste_ini
    dependency = @gnocchi_api_paste_ini.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@gnocchi_api_paste_ini)
    expect(dependency[0].source).to eq(anchor)
  end

end

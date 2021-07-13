Puppet::Type.type(:gnocchi_config).provide(
  :openstackconfig,
  :parent => Puppet::Type.type(:openstack_config).provider(:ruby)
) do

  def self.file_path
    '/etc/gnocchi/gnocchi.conf'
  end

end

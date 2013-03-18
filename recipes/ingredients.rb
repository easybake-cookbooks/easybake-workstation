node['easybake-workstation']['ingredients'].each do |data_bag,attrs|
  # getting all the the artifacts may be expensive
  # only retrieve if it hasn't been set in a role
  Chef::Log.fatal node['easybake-workstation']['ingredients'][data_bag]
#  if not node['easybake-workstation']['ingredients'][data_bag]['version']

  all_artifacts = search(data_bag,"os_#{node.platform}:#{node.platform_version} AND arch:#{node.kernel.machine}")
  Chef::Log.fatal 'first search'
  Chef::Log.fatal all_artifacts
  if all_artifacts.empty?
    all_artifacts = search(data_bag,"arch:#{node.kernel.machine}")
    Chef::Log.fatal 'second search'
    Chef::Log.fatal all_artifacts
  end
  
  node.default['easybake-workstation']['ingredients'][data_bag]['semantic_version']=all_artifacts.map{|v|
    v['semantic_version']}.flatten.uniq.sort{|a,b|c = Chef::VersionConstraint.new(">= #{a}").include?(b) ; c ? 0 : 1}.last
  #  end
  query = "semantic_version:#{node['easybake-workstation']['ingredients'][data_bag]['semantic_version']}"
  sorted=all_artifacts.map{|v|
    Chef::Log.fatal v['semantic_version']
    v['semantic_version']}.flatten.uniq.sort {|a,b|c = Chef::VersionConstraint.new(">= #{a}").include?(b) ; c ? 0 : 1}

  Chef::Log.fatal "sorted:#{sorted}"
  Chef::Log.fatal query
  if all_artifacts.map{|v|v['os'].keys}.flatten.uniq.sort.last.include? node.platform
    query += " AND os_#{node.platform}:#{node.platform_version} AND arch:#{node.kernel.machine}"
  end
  Chef::Log.fatal "super: #{query}"
  # if there isn't a version for this platform, we must want them all (windows, ubuntu)
  # Chef::Log.fatal all_artifacts.map{|v|v}
  # we need to update this to actually grab the virtualbox extensions and guest util iso

  search(data_bag,query).each do |ing|

    cache_file = File.join(Chef::Config[:file_cache_path], ing['filename'])
    # Populate the cache and checksums
    chksumf="#{cache_file}.checksum"
    rf = remote_file cache_file do
      source ing['source']
      checksum ing['checksum']
      not_if do
        (::File.exists? chksumf) && (open(chksumf).read == ing['checksum'])
      end
    end
    rf.run_action :create

    cs=file "#{cache_file}.checksum" do
      content ing['checksum']
    end
    cs.run_action :create

    node.default['easybake-workstation']['ingredients'][data_bag]['file']=cache_file
  end
end

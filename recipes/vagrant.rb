dpkg_package 'vagrant' do
  source node['easybake-workstation']['ingredients']['vagrant']['file']
end


vagrant_gem_binary = '/opt/vagrant/embedded/bin/gem'
chef_gem_binary = '/opt/chef/embedded/bin/gem'

gem_package 'vagrant-windows' do
  gem_binary vagrant_gem_binary
  options '--no-ri --no-rdoc'
  #source knife_acl_gem
end

gem_package 'em-winrm' do
  gem_binary vagrant_gem_binary
  options '--no-ri --no-rdoc'
  #source knife_acl_gem
end


veewee_gem_dir = ::File.join(Chef::Config.file_cache_path, 'veewee-gem')
#veewee_gem_dir = ::File.join('/tmp', 'veewee-gem')

veewee_gem = "#{veewee_gem_dir}/veewee-0.3.7.gem"

git veewee_gem_dir do
  repository "git://github.com/jedi4ever/veewee.git"
  not_if { ::File.exists? veewee_gem_dir }
end

execute 'build veewee gem' do
  command "gem build veewee.gemspec"
  creates veewee_gem
  cwd veewee_gem_dir
end

# useful for listing users within an org
gem_package 'veewee' do
  gem_binary vagrant_gem_binary
  options '--no-ri --no-rdoc'
  source veewee_gem
end


link "/opt/vagrant/bin/veewee" do
  to "/opt/vagrant/embedded/bin/veewee"
end

package 'openjdk-6-jre-headless'


file "/etc/profile.d/vagrant_path.sh" do
  content "export PATH=$PATH:/opt/vagrant/bin\n"
  mode 00644
end

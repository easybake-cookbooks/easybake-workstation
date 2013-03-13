bento_dir = ::File.join(Chef::Config.file_cache_path, 'bento')
#bento_dir = '/home/user/bento'

git bento_dir do
  repository "git://github.com/hh/bento.git"
  reference 'easybake'
  user 'user'
  group 'user'
#  repository "git://github.com/opscode/bento.git"
  not_if { ::File.exists? bento_dir }
end


# these to links allow us to run veewee vbox build definition_name
# from the cache, and have the resultant image show up in the cache
# all necessary iso should be in the file_cache_path
link ::File.join(Chef::Config.file_cache_path, 'iso') do
  to Chef::Config.file_cache_path
end

# all necessary iso should be in the file_cache_path
link ::File.join(Chef::Config.file_cache_path, 'definitions') do
  to ::File.join(bento_dir,'definitions')
end

template "#{bento_dir}/definitions/.windows/install-chef.bat"
template "#{bento_dir}/definitions/.common/chef-client.sh"
# added
template "#{bento_dir}/definitions/.common/install-vbox.bat"

if node['filesystem']['none'] && node['filesystem']['none']['fs_type'] == 'tmpfs'
  link '/home/user/VirtualBox VMs' do
    to node['filesystem']['none']['mount']
    owner 'user'
    only_if { node['filesystem']['none']['kb_available'].to_i > 5445364 }
  end
end

%w{windows-2008r2-standard ubuntu-12.04}.each do |boxname|
  # this creates the .box
  dot_box = ::File.join(Chef::Config.file_cache_path, "#{boxname}.box")
  vagrant_box = ::File.join('/home/user/.vagrant.d/boxes', boxname)

  vagrant_env = {
    'DISPLAY' => ':0.0',
    'PATH' => "/opt/vagrant/bin:#{ENV['PATH']}",
    'HOME' => "/home/user"
  }
  if ! ::File.exists? dot_box
    Chef::Log.warn "Creating #{dot_box}"

    directory Chef::Config[:file_cache_path] do
      user 'user'
      group 'user'
      recursive true
    end

    execute "veewee vbox build #{boxname} --force" do
      #action :nothing
      user 'user'
      group 'user'
      cwd Chef::Config.file_cache_path
      environment vagrant_env
      #notifies :run, "execute[veewee vbox validate #{boxname}]"
      creates dot_box # not really, but if this isn't here, start over
      #not_if "VBoxManage showvminfo #{boxname}", :user => 'user'
    end
    
    execute "veewee vbox validate #{boxname}" do
      action :nothing
      user 'user'
      group 'user'
      cwd Chef::Config.file_cache_path
      environment vagrant_env
    end
    
    execute "vagrant package --base #{boxname} --output '#{dot_box}'" do
      creates dot_box
      user 'user'
      group 'user'
      environment vagrant_env
      cwd Chef::Config.file_cache_path
    end
  end

  execute "vagrant box add '#{boxname}' '#{Chef::Config[:file_cache_path]}/#{boxname}.box'" do
    creates vagrant_box
    user 'user'
    group 'user'
    environment vagrant_env
    cwd Chef::Config.file_cache_path
  end
end

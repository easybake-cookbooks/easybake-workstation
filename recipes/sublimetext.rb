execute "install sublimetext2" do
  command <<-EOH
tar -jxf '#{node['easybake-workstation']['ingredients']['sublimetext']['file']}' -C /opt
EOH
  creates '/opt/Sublime Text 2'
end

link "/opt/SublimeText2" do
  to "/opt/Sublime\ Text\ 2"
end

file "/etc/profile.d/sublime_path.sh" do
  content <<-EOS
    export PATH=$PATH:/opt/SublimeText2
    export EDITOR=/opt/SublimeText2/sublime_text
  EOS
  mode 00644
end

# hardcoding for now... FIXME later
username='user'

cwd = "/home/#{username}/"
# directory doesn't set owner for containing directories... 
# welcome to my cheesy work around
%w{.config sublime-text-2 Packages User}.each do |subdir|
  cwd = ::File.join(cwd,subdir)
  directory cwd do
    recursive true
    owner "#{username}"
  end
end

package "ttf-inconsolata"

cookbook_file "/home/#{username}/.config/sublime-text-2/Packages/User/Preferences.sublime-settings" do
  source "Preferences.sublime-settings"
  owner "#{username}"
end

cookbook_file "/home/#{username}/.config/sublime-text-2/Packages/User/Ruby.sublime-settings" do
  source "Ruby.sublime-settings"
  owner "#{username}"
end

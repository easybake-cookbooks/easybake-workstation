#bento_dir = ::File.join(Chef::Config.file_cache_path, 'bento')
bento_dir = '/home/user/bento'

git bento_dir do
  # we are using 12.04.2, waiting on merge of:
  repository "git://github.com/cassianoleal/bento.git"
  reference 'patch-1'
  user 'user'
  group 'user'
#  repository "git://github.com/opscode/bento.git"
  not_if { ::File.exists? bento_dir }
end

# all necessary iso should be in the file_cache_path
link "#{bento_dir}/iso" do
  to Chef::Config.file_cache_path
end




dpkg_package 'virtualbox-4.2' do
  source node['easybake-workstation']['ingredients']['virtualbox']['file']
end

dpkg_package 'virtualbox' do
  source node['easybake-workstation']['ingredients']['virtualbox']['file']
end

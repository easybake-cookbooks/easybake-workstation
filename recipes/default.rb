%w{git g++ libxml2-dev libxslt-dev}.each do |p|
  package p
end

include_recipe 'easybake-workstation::ingredients'
include_recipe 'easybake-workstation::virtualbox'
include_recipe 'easybake-workstation::vagrant'
include_recipe 'easybake-workstation::sublimetext'
include_recipe 'easybake-workstation::bento'



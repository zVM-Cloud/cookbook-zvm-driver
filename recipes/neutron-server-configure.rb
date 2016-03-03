# encoding: UTF-8
#
# =================================================================
# Licensed Materials - Property of IBM
#
# (c) Copyright IBM Corp. 2014, 2015 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
# =================================================================
#
# Cookbook Name:: ibm-openstack-zvm-driver
# Recipe:: neutron-server-configure
#

# Make Openstack object available in Chef::Recipe
class ::Chef::Recipe
  include ::Openstack
end

service 'neutron-server' do
  service_name node['openstack']['network']['platform']['neutron_server_service']
  supports status: true, restart: true

  action :nothing
end

# Install/Upgrade neutron z/VM agent
node['ibm-openstack']['zvm-driver']['packages']['network'].each do |pkg|
  package pkg do
    action :upgrade
    notifies :restart, 'service[neutron-server]', :delayed
  end
end

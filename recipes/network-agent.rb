# encoding: UTF-8
#
# Cookbook Name:: openstack-zvm-driver
# Recipe:: network-agent
#
# Copyright 2014, 2015 IBM Corp.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Make Openstack object available in Chef::Recipe
class ::Chef::Recipe
  include ::Openstack
end

include_recipe 'openstack-common::openrc'

hosts = node['ibm-openstack']['zvm-driver']['hosts']

# Install/Upgrade neutron z/VM agent
node['ibm-openstack']['zvm-driver']['packages']['network'].each do |pkg|
  package pkg do
    action :upgrade
  end
end

service 'neutron-zvm-agent' do
  action [:disable, :stop]
end

include_recipe 'openstack-network'

platform_options = node['openstack']['network']['platform']

# Create directory for z/VM plugin config
directory '/etc/neutron/plugins/zvm' do
  owner platform_options['user']
  group platform_options['group']
  mode  00700
  action :create
end

hosts.each do |host|
  # Modify neutron plugin attributes by host
  ibm_openstack_zvm_driver_modify "neutron plugin #{host}" do
    host host
    action :modify_neutron
  end

  if node['ibm-openstack']['zvm-driver'][host]['external_vswitch_mappings']
    zvm_external_vswitch_mappings = node['ibm-openstack']['zvm-driver'][host]['external_vswitch_mappings'].split(';')
  else
    zvm_external_vswitch_mappings = []
  end

  zvm_xcat_password = get_user_password 'xcat', node['ibm-openstack']['zvm-driver'][host]['xcat']['server']

  # Create/Update service file neutron-zvm-agent-<host> for each compute host
  template "/etc/init.d/neutron-zvm-agent-#{host}" do
    source 'service-neutron-zvm-agent.erb'
    owner platform_options['user']
    group platform_options['group']
    mode 00755
    action :create
    variables(
      host: host
    )
  end

  # Create/Update ml2_conf-<host>.ini for each compute host
  template "/etc/neutron/plugins/ml2/ml2_conf-#{host}.ini" do
    cookbook 'openstack-network'
    source 'plugins/ml2/ml2_conf.ini.erb'
    owner platform_options['user']
    group platform_options['group']
    mode 00640
    action :create
    unless node.run_list.expand(node.chef_environment).recipes.include?('openstack-network::server')
      notifies :restart, 'service[neutron-server]', :delayed
    end
  end

  # Create/Update neutron-zvm-plugin-<host>.ini for each compute host
  template "/etc/neutron/plugins/zvm/neutron_zvm_plugin-#{host}.ini" do
    source 'neutron_zvm_plugin.ini.erb'
    mode 00640
    owner platform_options['user']
    group platform_options['group']
    action :create
    variables(
      zvm_xcat_password: zvm_xcat_password,
      zvm_external_vswitch_mappings: zvm_external_vswitch_mappings,
      host: host
    )
    notifies :restart, "service[neutron-zvm-agent-#{host}]", :delayed
  end
end

hosts.each do |host|
  # Enable neutron zvm agent service for each compute host
  service "neutron-zvm-agent-#{host}" do
    supports status: true, restart: true
    action [:enable, :start]
    subscribes :restart, 'template[/etc/neutron/neutron.conf]', :delayed
    subscribes :restart, 'template[/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini]', :delayed
    subscribes :restart, "template[/etc/neutron/plugins/ml2/ml2_conf-#{host}.ini]", :delayed
    # Because z/VM compute uses neutron-zvm-agent instead of neutron-openvswitch-agent,
    # make sure neutron-openvswitch-agent is disabled and stopped if the recpie openstack-network::openvswitch,
    # is in the run_list.
    if node.run_list.expand(node.chef_environment).recipes.include?('openstack-network::openvswitch')
      notifies :disable, 'service[neutron_openvswitch_agent_service]', :delayed
      notifies :stop, 'service[neutron_openvswitch_agent_service]', :delayed
    end
    unless node.run_list.expand(node.chef_environment).recipes.include?('openstack-network::server')
      notifies :disable, 'service[neutron-server]', :delayed
      notifies :stop, 'service[neutron-server]', :delayed
    end
  end
end

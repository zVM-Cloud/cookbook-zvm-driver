# encoding: UTF-8
#
# Cookbook Name:: openstack-zvm-driver
# Provider:: modify
#
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#

action :modify_nova do
  zvm_driver_host = node['ibm-openstack']['zvm-driver'][new_resource.host]

  if zvm_driver_host['xcat']
    %w{connection_timeout image_clean_period free_space_threshold server username master}.each do |attr|
      if zvm_driver_host['xcat'][attr]
        node.default['ibm-openstack']['zvm-driver']['xcat'].delete(attr)
        node.force_override['ibm-openstack']['zvm-driver']['xcat'][attr] = zvm_driver_host['xcat'][attr] # :pragma-foodcritic: ~FC019
      end
    end
  end

  if zvm_driver_host['config']
    if zvm_driver_host['config']['ram_allocation_ratio']
      node.default['ibm-openstack']['zvm-driver']['config'].delete('ram_allocation_ratio')
      node.force_override['ibm-openstack']['zvm-driver']['config']['ram_allocation_ratio'] = zvm_driver_host['config']['ram_allocation_ratio'] # :pragma-foodcritic: ~FC019
    end
  end

  if zvm_driver_host['config_drive']
    %w{format inject_password}.each do |attr|
      if zvm_driver_host['config_drive'][attr]
        node.default['ibm-openstack']['zvm-driver']['config_drive'].delete(attr)
        node.force_override['ibm-openstack']['zvm-driver']['config_drive'][attr] = zvm_driver_host['config_drive'][attr] # :pragma-foodcritic: ~FC019
      end
    end
  end

  if zvm_driver_host['image']
    %w{tmp_path cache_manager_interval}.each do |attr|
      if zvm_driver_host['image'][attr]
        node.default['ibm-openstack']['zvm-driver']['image'].delete(attr)
        node.force_override['ibm-openstack']['zvm-driver']['image'][attr] = zvm_driver_host['image'][attr] # :pragma-foodcritic: ~FC019
      end
    end
  end

  %w{rpc_response_timeout reachable_timeout vmrelocate_force}.each do |attr|
    if zvm_driver_host[attr]
      node.default['ibm-openstack']['zvm-driver'].delete(attr)
      node.force_override['ibm-openstack']['zvm-driver'][attr] = zvm_driver_host[attr] # :pragma-foodcritic: ~FC019
    end
  end

  node.default['openstack']['compute'].delete('driver')
  node.default['openstack']['compute']['config'].delete('force_config_drive')
  node.default['openstack']['compute']['config'].delete('ram_allocation_ratio')
  node.default['openstack']['compute'].delete('rpc_response_timeout')
  node.force_override['openstack']['compute']['driver'] = 'nova.virt.zvm.ZVMDriver' # :pragma-foodcritic: ~FC019
  node.force_override['openstack']['compute']['config']['force_config_drive'] = 'True' # :pragma-foodcritic: ~FC019
  node.force_override['openstack']['compute']['config']['ram_allocation_ratio'] = node['ibm-openstack']['zvm-driver']['config']['ram_allocation_ratio'] # :pragma-foodcritic: ~FC019
  node.force_override['openstack']['compute']['rpc_response_timeout'] = node['ibm-openstack']['zvm-driver']['rpc_response_timeout'] # :pragma-foodcritic: ~FC019
  node.override!['openstack']['compute']['config']['compute_monitors'] = [] # :pragma-foodcritic: ~FC019

  new_resource.updated_by_last_action(true)
end

action :modify_neutron do
  zvm_driver_host = node['ibm-openstack']['zvm-driver'][new_resource.host]

  if zvm_driver_host['polling_interval']
    node.default['ibm-openstack']['zvm-driver'].delete('polling_interval')
    node.force_override['ibm-openstack']['zvm-driver']['polling_interval'] = zvm_driver_host['polling_interval'] # :pragma-foodcritic: ~FC019
  end

  if zvm_driver_host['xcat']
    %w{server username zhcp_nodename timeout mgt_ip mgt_mask}.each do |attr|
      if zvm_driver_host['xcat'][attr]
        node.default['ibm-openstack']['zvm-driver']['xcat'].delete(attr)
        node.force_override['ibm-openstack']['zvm-driver']['xcat'][attr] = zvm_driver_host['xcat'][attr] # :pragma-foodcritic: ~FC019
      end
    end
  end

  if zvm_driver_host['ml2']
    %w{type_drivers tenant_network_types flat_networks network_vlan_ranges}.each do |attr|
      if zvm_driver_host['ml2'][attr]
        node.default['ibm-openstack']['zvm-driver']['ml2'].delete(attr)
        node.force_override['ibm-openstack']['zvm-driver']['ml2'][attr] = zvm_driver_host['ml2'][attr] # :pragma-foodcritic: ~FC019
      end
    end
  end

  %w{type_drivers tenant_network_types mechanism_drivers flat_networks network_vlan_ranges}.each do |attr|
    node.default['openstack']['network']['ml2'].delete(attr)
  end
  node.force_override['openstack']['network']['ml2']['type_drivers'] = node['ibm-openstack']['zvm-driver']['ml2']['type_drivers'] # :pragma-foodcritic: ~FC019
  node.force_override['openstack']['network']['ml2']['tenant_network_types'] = node['ibm-openstack']['zvm-driver']['ml2']['tenant_network_types'] # :pragma-foodcritic: ~FC019
  node.force_override['openstack']['network']['ml2']['mechanism_drivers'] = node['ibm-openstack']['zvm-driver']['ml2']['mechanism_drivers'] # :pragma-foodcritic: ~FC019
  node.force_override['openstack']['network']['ml2']['flat_networks'] = node['ibm-openstack']['zvm-driver']['ml2']['flat_networks'] # :pragma-foodcritic: ~FC019
  node.force_override['openstack']['network']['ml2']['network_vlan_ranges'] = node['ibm-openstack']['zvm-driver']['ml2']['network_vlan_ranges'] # :pragma-foodcritic: ~FC019

  new_resource.updated_by_last_action(true)
end

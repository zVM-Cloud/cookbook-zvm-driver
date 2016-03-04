# encoding: UTF-8
#
# Cookbook Name:: openstack-zvm-driver
# Recipe:: neutron-server-configure
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

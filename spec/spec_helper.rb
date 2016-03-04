# encoding: UTF-8
#
# Cookbook Name:: openstack-zvm-driver
# Recipe:: default
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

require 'chefspec'

require 'chef/application'
require 'securerandom'

ChefSpec::Coverage.start! { add_filter 'openstack-zvm-driver' }

::LOG_LEVEL = :fatal
::REDHAT_OPTS = {
  platform: 'redhat',
  version: '7.0',
  log_level: LOG_LEVEL,
  step_into: ['ibm_openstack_zvm_driver_ssh', 'ibm_openstack_zvm_driver_modify']
}

shared_context 'zvm_driver_compute_stubs' do
  before do
    allow_any_instance_of(Chef::Recipe).to receive(:get_user_password)
      .with('xcat', 'xcat-server')
      .and_return('password')
    allow_any_instance_of(Chef::Recipe).to receive(:get_user_password)
      .with('zlinuxroot', 'host')
      .and_return('password')
    allow_any_instance_of(Chef::Recipe).to receive(:get_user_password)
      .with('xcatmnadmin', 'xcat-server')
      .and_return('password')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('db', 'nova')
      .and_return('nova')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'rabbitmq')
      .and_return('rabbitmq')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'qpid')
      .and_return('qpid')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('service', 'openstack-network')
      .and_return('neutron')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('service', 'openstack-compute')
      .and_return('nova')
    allow(::Net::SSH).to receive(:start)
  end
end

shared_context 'zvm_driver_network_stubs' do
  before do
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('db', 'neutron')
      .and_return('neutron')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('service', 'openstack-network')
      .and_return('openstack-network')
    allow_any_instance_of(Chef::Recipe).to receive(:get_user_password)
      .with('xcat', 'xcat-server')
      .and_return('password')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'guest')
      .and_return('guest')
  end
end

shared_context 'compute_common_stubs' do
  before do
    allow_any_instance_of(Chef::Recipe).to receive(:rabbit_servers)
      .and_return '1.1.1.1:5672,2.2.2.2:5672'
    allow_any_instance_of(Chef::Recipe).to receive(:address_for)
      .with('lo')
      .and_return '127.0.1.1'
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('token', 'openstack_identity_bootstrap_token')
      .and_return('bootstrap-token')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('token', 'neutron_metadata_secret')
      .and_return('metadata-secret')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password) # this is the rbd_uuid default name
      .with('token', 'rbd_secret_uuid')
      .and_return '00000000-0000-0000-0000-000000000000'
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('token', 'openstack_vmware_secret_name')
      .and_return 'vmware_secret_name'
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('db', anything)
      .and_return('')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'guest')
      .and_return('mq-pass')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'admin')
      .and_return('admin')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('service', 'openstack-compute')
      .and_return('nova-pass')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('service', 'openstack-bare-metal')
      .and_return('openstack-bare-metal')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('service', 'openstack-network')
      .and_return('neutron-pass')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('service', 'rbd_block_storage')
      .and_return 'cinder-rbd-pass'
    allow_any_instance_of(Chef::Recipe).to receive(:memcached_servers).and_return []
    allow_any_instance_of(Chef::Recipe).to receive(:system)
      .with("grub2-set-default 'openSUSE GNU/Linux, with Xen hypervisor'")
      .and_return(true)
    allow(Chef::Application).to receive(:fatal!)
    allow(SecureRandom).to receive(:hex) { 'ad3313264ea51d8c6a3d1c5b140b9883' }
    stub_command('nova-manage network list | grep 192.168.100.0/24').and_return(false)
    stub_command('nova-manage network list | grep 192.168.200.0/24').and_return(false)
    stub_command("nova-manage floating list |grep -E '.*([0-9]{1,3}[.]){3}[0-9]{1,3}*'").and_return(false)
    stub_command('virsh net-list | grep -q default').and_return(true)
    stub_command('ovs-vsctl br-exists br-int').and_return(true)
    stub_command('ovs-vsctl br-exists br-tun').and_return(true)
    stub_command('virsh secret-list | grep 00000000-0000-0000-0000-000000000000').and_return(false)
    stub_command("virsh secret-get-value 00000000-0000-0000-0000-000000000000 | grep 'cinder-rbd-pass'").and_return(false)
  end
end

shared_context 'network-common-stubs' do
  before do
    allow_any_instance_of(Chef::Recipe).to receive(:rabbit_servers)
      .and_return('1.1.1.1:5672,2.2.2.2:5672')
    allow_any_instance_of(Chef::Recipe).to receive(:config_by_role)
      .with('rabbitmq-server', 'queue').and_return(
        host: 'rabbit-host',
        port: 'rabbit-port'
      )
    allow_any_instance_of(Chef::Recipe).to receive(:config_by_role)
      .with('glance-api', 'glance').and_return []
    allow_any_instance_of(Chef::Recipe).to receive(:secret)
      .with('secrets', 'openstack_identity_bootstrap_token')
      .and_return('bootstrap-token')
    allow_any_instance_of(Chef::Recipe).to receive(:secret)
      .with('secrets', 'neutron_metadata_secret')
      .and_return('metadata-secret')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('db', anything)
      .and_return('neutron')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('service', 'openstack-network')
      .and_return('neutron-pass')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'guest')
      .and_return('mq-pass')
    allow(Chef::Application).to receive(:fatal!)
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('service', 'openstack-compute')
      .and_return('nova-pass')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'admin')
      .and_return('admin')
    allow_any_instance_of(Chef::Resource::RubyBlock).to receive(:openstack_command_env)
      .with('admin', 'admin')
      .and_return({})
    allow_any_instance_of(Chef::Resource::RubyBlock).to receive(:identity_uuid)
      .with('tenant', 'name', 'service', {})
      .and_return('000-UUID-FROM-CLI')

    stub_command('dpkg -l | grep openvswitch-switch | grep 1.10.2-1').and_return(true)
    stub_command('ovs-vsctl br-exists br-int').and_return(false)
    stub_command('ovs-vsctl br-exists br-tun').and_return(false)
    stub_command('ip link show eth1').and_return(false)
  end
end

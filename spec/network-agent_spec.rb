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

require_relative 'spec_helper'

describe 'openstack-zvm-driver::network-agent' do
  describe 'redhat' do
    include_context 'network-common-stubs'
    include_context 'zvm_driver_network_stubs'
    let(:runner) { ChefSpec::Runner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      node.set['openstack']['compute']['network']['service_type'] = 'neutron'
      node.set['ibm-openstack']['zvm-driver']['hosts'] = ['host']
      node.set['ibm-openstack']['zvm-driver']['host']['xcat']['server'] = 'xcat-server'
      node.set['ibm-openstack']['zvm-driver']['host']['external_vswitch_mappings'] = 'datanet1:6243;datanet3:6343'
      node.set['ibm-openstack']['zvm-driver']['host']['ml2']['type_drivers'] = 'flat,vlan'
      node.set['ibm-openstack']['zvm-driver']['host']['polling_interval'] = 5
      node.set['ibm-openstack']['zvm-driver']['host']['xcat']['timeout'] = 10
      runner.converge(described_recipe)
    end

    zvm_dir = '/etc/neutron/plugins/zvm'

    it 'force overrides attributes' do
      expect(chef_run.node['ibm-openstack']['zvm-driver']['polling_interval']).to eq(5)
      expect(chef_run.node['ibm-openstack']['zvm-driver']['xcat']['timeout']).to eq(10)
      expect(chef_run.node['openstack']['network']['ml2']['type_drivers']).to eq('flat,vlan')
    end

    it 'upgrades neutron zvm agent' do
      expect(chef_run).to upgrade_package('neutron-zvm-plugin')
    end

    it 'includes openstack-common::openrc recipe' do
      expect(chef_run).to include_recipe('openstack-common::openrc')
    end

    it 'includes openstack-network::default recipe' do
      expect(chef_run).to include_recipe('openstack-network')
    end

    it 'creates neutron zvm agent conf directory' do
      expect(chef_run).to create_directory(zvm_dir).with(
        owner: 'neutron',
        group: 'neutron',
        mode: 00700
      )
    end

    it 'creates neutron zvm agent service' do
      expect(chef_run).to create_template('/etc/init.d/neutron-zvm-agent-host').with(
        owner: 'neutron',
        group: 'neutron',
        mode: 00755
      )
      expect(chef_run).to render_file('/etc/init.d/neutron-zvm-agent-host').with_content('plugin=zvm-agent-host')
    end

    it 'create ml2_conf-host.ini' do
      expect(chef_run).to create_template('/etc/neutron/plugins/ml2/ml2_conf-host.ini').with(
        owner: 'neutron',
        group: 'neutron',
        mode: 00640
      )
      expect(chef_run).to render_file('/etc/neutron/plugins/ml2/ml2_conf-host.ini').with_content('type_drivers = flat,vlan')
    end

    describe '/etc/neutron/plugins/zvm/neutron_zvm_plugin-host.ini' do
      let(:file) { chef_run.template('/etc/neutron/plugins/zvm/neutron_zvm_plugin-host.ini') }
      it 'creates /etc/neutron/plugins/zvm/neutron_zvm_plugin-host.ini' do
        expect(chef_run).to create_template(file.name).with(
          owner: 'neutron',
          group: 'neutron',
          mode: 00640
        )
      end
    end

    it 'disables or stops neutron-zvm-agent' do
      expect(chef_run).to disable_service('neutron-zvm-agent')
      expect(chef_run).to stop_service('neutron-zvm-agent')
    end

    it 'enables or starts neutron-zvm-agent-host' do
      expect(chef_run).to enable_service('neutron-zvm-agent-host')
      expect(chef_run).to start_service('neutron-zvm-agent-host')
    end
  end
end

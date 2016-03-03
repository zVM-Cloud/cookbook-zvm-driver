# encoding: UTF-8
#
# Cookbook Name:: ibm-openstack-zvm-driver
# Recipe:: compute
#
# =================================================================
# Licensed Materials - Property of IBM
#
# (c) Copyright IBM Corp. 2014 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
# =================================================================

require_relative 'spec_helper'

describe 'ibm-openstack-zvm-driver::compute' do
  describe 'redhat' do
    include_context 'compute_common_stubs'
    include_context 'zvm_driver_compute_stubs'
    let(:runner) { ChefSpec::Runner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      stub_command("grep -Fxq '' ~nova/.ssh/authorized_keys").and_return(false)
      shellout = double
      cmd = double
      cho = double
      allow(Mixlib::ShellOut).to receive(:new).and_return(shellout)
      allow(shellout).to receive(:run_command).and_return(cmd)
      allow(cmd).to receive(:stdout).and_return(cho)
      allow(cho).to receive(:chomp).and_return('~nova')
      node.set['ibm-openstack']['zvm-driver']['hosts'] = ['host']
      node.set['ibm-openstack']['zvm-driver']['host']['xcat']['server'] = 'xcat-server'
      node.set['ibm-openstack']['zvm-driver']['host']['config']['ram_allocation_ratio'] = 2
      node.set['ibm-openstack']['zvm-driver']['host']['rpc_response_timeout'] = 60
      node.set['ibm-openstack']['zvm-driver']['host']['image']['tmp_path'] = 'var/lib/nova/tmp'
      node.set['ibm-openstack']['zvm-driver']['host']['config_drive']['format'] = 'gz'
      node.set['ibm-openstack']['zvm-driver']['host']['config_drive']['inject_password'] = true
      node.set['ibm-openstack']['zvm-driver']['host']['reachable_timeout'] = 100
      node.set['ibm-openstack']['zvm-driver']['host']['xcat']['connection_timeout'] = 1
      node.set['ibm-openstack']['zvm-driver']['host']['image']['cache_manager_interval'] = 1000
      node.set['ibm-openstack']['zvm-driver']['host']['xcat']['image_clean_period'] = 50
      node.set['ibm-openstack']['zvm-driver']['host']['xcat']['free_space_threshold'] = 600
      node.set['ibm-openstack']['zvm-driver']['host']['vmrelocate_force'] = 'FORCE'
      runner.converge(described_recipe)
    end

    nova_home = '~nova'
    ssh_path = "#{nova_home}/.ssh"
    auth_key = "#{nova_home}/.ssh/authorized_keys"

    it 'force_override attributes' do
      expect(chef_run.node['openstack']['compute']['driver']).to eq('nova.virt.zvm.ZVMDriver')
      expect(chef_run.node['openstack']['compute']['config']['force_config_drive']).to eq('True')
      expect(chef_run.node['openstack']['compute']['config']['ram_allocation_ratio']).to eq(2)
      expect(chef_run.node['openstack']['compute']['config']['compute_monitors']).to eq([])
      expect(chef_run.node['openstack']['compute']['rpc_response_timeout']).to eq(60)
      expect(chef_run.node['ibm-openstack']['zvm-driver']['image']['tmp_path']).to eq('var/lib/nova/tmp')
      expect(chef_run.node['ibm-openstack']['zvm-driver']['config_drive']['format']).to eq('gz')
      expect(chef_run.node['ibm-openstack']['zvm-driver']['config_drive']['inject_password']).to eq(true)
      expect(chef_run.node['ibm-openstack']['zvm-driver']['reachable_timeout']).to eq(100)
      expect(chef_run.node['ibm-openstack']['zvm-driver']['xcat']['connection_timeout']).to eq(1)
      expect(chef_run.node['ibm-openstack']['zvm-driver']['image']['cache_manager_interval']).to eq(1000)
      expect(chef_run.node['ibm-openstack']['zvm-driver']['xcat']['image_clean_period']).to eq(50)
      expect(chef_run.node['ibm-openstack']['zvm-driver']['xcat']['free_space_threshold']).to eq(600)
      expect(chef_run.node['ibm-openstack']['zvm-driver']['vmrelocate_force']).to eq('FORCE')
    end

    it 'upgrades nova-zvm-virt-driver pakcage' do
      expect(chef_run).to upgrade_package('nova-zvm-virt-driver')
    end

    it 'includes openstack-compute::nova-common recipe' do
      expect(chef_run).to include_recipe('openstack-compute::nova-common')
    end

    it 'includes openstack-common::openrc recipe' do
      expect(chef_run).to include_recipe('openstack-common::openrc')
    end

    it 'upgrades openstack-nova-compute pakcage' do
      expect(chef_run).to upgrade_package('openstack-nova-compute')
    end

    it 'creates openstack-nova-compute service' do
      expect(chef_run).to create_template('/etc/init.d/openstack-nova-compute-host').with(
        mode: 00755
      )
    end

    it 'creates nova-host.conf' do
      expect(chef_run).to create_template('/etc/nova/nova-host.conf').with(
        owner: 'nova',
        group: 'nova',
        mode: 00640
      )
    end

    it 'compute driver is nova.virt.zvm.ZVMDriver' do
      expect(chef_run).to render_file('/etc/nova/nova-host.conf').with_content('compute_driver=nova.virt.zvm.ZVMDriver')
    end

    it 'disables or stops nova-compute on boot' do
      expect(chef_run).to disable_service('openstack-nova-compute')
      expect(chef_run).to stop_service('openstack-nova-compute')
    end

    it 'enables or starts nova-compute-host on boot' do
      expect(chef_run).to enable_service('openstack-nova-compute-host')
      expect(chef_run).to start_service('openstack-nova-compute-host')
    end

    it 'creates nova_home directory' do
      expect(chef_run).to create_directory(nova_home).with(
        owner: 'nova',
        group: 'nova',
        mode: 00755
      )
    end

    it 'creates .ssh directory' do
      expect(chef_run).to create_directory(ssh_path).with(
        owner: 'nova',
        group: 'nova',
        mode: 00700
      )
    end

    it 'creates file authorized_keys' do
      expect(chef_run).to create_file_if_missing(auth_key)
    end

    it 'execute cmd append xcat public key to compute authorized_keys' do
      expect(chef_run).to run_execute("echo '' >> #{auth_key}")
    end

    it 'execute cmd set selinux on ssh nova' do
      expect(chef_run).to run_execute("chcon -R -t ssh_home_t #{nova_home}")
    end
  end
end

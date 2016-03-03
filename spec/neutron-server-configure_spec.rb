# encoding: UTF-8
#
# Cookbook Name:: ibm-openstack-zvm-driver
# Recipe:: neutron-server-configure
#
# =================================================================
# Licensed Materials - Property of IBM
#
# (c) Copyright IBM Corp. 2014, 2015 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
# =================================================================

require_relative 'spec_helper'

describe 'ibm-openstack-zvm-driver::neutron-server-configure' do
  describe 'redhat' do
    let(:runner) { ChefSpec::Runner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      runner.converge(described_recipe)
    end

    it 'upgrades neutron zvm agent' do
      expect(chef_run).to upgrade_package('neutron-zvm-plugin')
    end
  end
end

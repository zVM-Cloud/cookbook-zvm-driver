# encoding: UTF-8
#
# =================================================================
# Licensed Materials - Property of IBM
#
# (c) Copyright IBM Corp. 2014 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
# =================================================================
#
# Cookbook Name:: ibm-openstack-zvm-driver
# Resource:: ssh
#

actions :set_dir, :authorize

default_action :set_dir

attribute :nova_user, kind_of: String, required: true
attribute :nova_group, kind_of: String, required: true
attribute :host, kind_of: String, required: false
attribute :mnpass, kind_of: String, required: true

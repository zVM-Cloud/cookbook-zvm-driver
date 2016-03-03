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
# Resource:: modify
#

actions :modify_nova, :modify_neutron

default_action :modify_nova

attribute :host, kind_of: String, required: true

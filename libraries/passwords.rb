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
# Library:: passwords
#

def get_user_password(id, index)
  key_path = node['openstack']['secret']['key_path']
  user_passwords = node['openstack']['secret']['user_passwords_data_bag']
  ::Chef::Log.info "Loading encrypted databag #{user_passwords}.#{id}.#{index} using key at #{key_path}"
  secret = ::Chef::EncryptedDataBagItem.load_secret key_path
  user_password = ::Chef::EncryptedDataBagItem.load(user_passwords, id, secret)[index]
  unless user_password
    return ::Chef::EncryptedDataBagItem.load(user_passwords, id, secret)[id]
  end
  user_password
end

# encoding: UTF-8
#
# Cookbook Name:: openstack-zvm-driver
# Library:: passwords
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

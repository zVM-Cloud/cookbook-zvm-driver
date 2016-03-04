# encoding: UTF-8
#
# Cookbook Name:: openstack-zvm-driver
# Provider:: ssh
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

action :set_dir do
  nova_home = Mixlib::ShellOut.new("echo ~#{new_resource.nova_user}").run_command.stdout.chomp
  auth_key = "#{nova_home}/.ssh/authorized_keys"

  directory nova_home do
    owner new_resource.nova_user
    group new_resource.nova_group
    mode 00755
    action :create
  end

  directory "#{nova_home}/.ssh" do
    owner new_resource.nova_user
    group new_resource.nova_group
    mode 00700
    action :create
  end

  file auth_key do
    owner new_resource.nova_user
    group new_resource.nova_group
    mode 00644
    action :create_if_missing
  end

  execute 'set SELinux policy to allow non-password ssh by xCAT user' do
    user new_resource.nova_user
    command "chcon -R -t ssh_home_t #{nova_home}"
    not_if { Mixlib::ShellOut.new('getenforce').run_command.stdout.chomp.match(/Disabled/) }
  end

  new_resource.updated_by_last_action(true)
end

action :authorize do
  zvm_driver_host = node['ibm-openstack']['zvm-driver'][new_resource.host]
  nova_home = Mixlib::ShellOut.new("echo ~#{new_resource.nova_user}").run_command.stdout.chomp
  auth_key = "#{nova_home}/.ssh/authorized_keys"
  xcat_server = node['ibm-openstack']['zvm-driver']['xcat']['server']
  if zvm_driver_host['xcat'] && zvm_driver_host['xcat']['server']
    xcat_server = zvm_driver_host['xcat']['server']
  end
  if zvm_driver_host['xcat'] && zvm_driver_host['xcat']['mnadmin']
    node.force_override['ibm-openstack']['zvm-driver']['xcat']['mnadmin'] = zvm_driver_host['xcat']['mnadmin'] # :pragma-foodcritic: ~FC019
  end
  xcat_mn_admin = node['ibm-openstack']['zvm-driver']['xcat']['mnadmin']
  xcat_mn_pass = new_resource.mnpass
  xcat_rsa_pub = ''
  xcat_pub_file = "#{nova_home}/.ssh/#{xcat_server}"

  unless ::File.exists?(xcat_pub_file)
    begin
      ::Timeout.timeout(10) do
        Net::SSH.start(xcat_server, xcat_mn_admin, password: xcat_mn_pass) do |ssh|
          xcat_rsa_pub = ssh.exec!('cat /root/.ssh/id_rsa.pub')
          if xcat_rsa_pub.include?'No such file or directory'
            fail '/root/.ssh/id_rsa.pub does not exist in xCAT server. Please do another deployment after the issue fixed.'
          end
        end
      end
    rescue Timeout::Error
      raise "Error adding xCAT server's public key to nova user's authorized_keys. It may be caused by bad network connection to xCAT server or authentication failure. You can try to check the password for xcat mnadmin user in data bag, or check the xCAT server ssh connection. Please do another deployment after the issue fixed."
    end

    execute 'append xcat public key to compute node authorized_keys list' do
      user new_resource.nova_user
      command "echo '#{xcat_rsa_pub}' >> #{auth_key}"
    end

    file xcat_pub_file do
      owner new_resource.nova_user
      group new_resource.nova_group
      mode 00644
    end
  end

  new_resource.updated_by_last_action(true)
end

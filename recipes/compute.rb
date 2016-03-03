# encoding: UTF-8
#
# =================================================================
# Licensed Materials - Property of IBM
#
# (c) Copyright IBM Corp. 2014, 2015 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
# =================================================================
#
# Cookbook Name:: ibm-openstack-zvm-driver
# Recipe:: compute
#

require 'net/ssh'

# Make Openstack object available in Chef::Recipe
class ::Chef::Recipe
  include ::Openstack
end

include_recipe 'openstack-compute::nova-common'
include_recipe 'openstack-common::logging' if node['openstack']['compute']['syslog']['use']
include_recipe 'openstack-common::openrc'

hosts = node['ibm-openstack']['zvm-driver']['hosts']

db_user = node['openstack']['db']['compute']['username']
db_pass = get_password 'db', 'nova'
sql_connection = db_uri('compute', db_user, db_pass)
mq_service_type = node['openstack']['mq']['compute']['service_type']

if mq_service_type == 'rabbitmq'
  node['openstack']['mq']['compute']['rabbit']['ha'] && (rabbit_hosts = rabbit_servers)
  mq_password = get_password 'user', node['openstack']['mq']['compute']['rabbit']['userid']
elsif mq_service_type == 'qpid'
  mq_password = get_password 'user', node['openstack']['mq']['compute']['qpid']['username']
end

memcache_servers = memcached_servers.join ','

# find the node attribute endpoint settings for the server holding a given role
identity_endpoint = internal_endpoint 'identity-internal'
xvpvnc_endpoint = endpoint 'compute-xvpvnc' || {}
xvpvnc_bind = endpoint 'compute-xvpvnc-bind' || {}
novnc_endpoint = endpoint 'compute-novnc' || {}
novnc_bind = endpoint 'compute-novnc-bind' || {}
vnc_bind = endpoint 'compute-vnc-bind' || {}
vnc_proxy_bind = endpoint 'compute-vnc-proxy-bind' || {}
compute_api_bind = endpoint 'compute-api-bind' || {}
compute_api_endpoint = internal_endpoint 'compute-api' || {}
compute_metadata_api_bind = endpoint 'compute-metadata-api-bind' || {}
ec2_api_bind = endpoint 'compute-ec2-api-bind' || {}
network_endpoint = internal_endpoint 'network-api' || {}
image_endpoint = internal_endpoint 'image-api'

if node['openstack']['compute']['network']['service_type'] == 'neutron'
  neutron_admin_password = get_password 'service', 'openstack-network'
  neutron_metadata_proxy_shared_secret = get_password 'token', 'neutron_metadata_secret'
end

if node['openstack']['compute']['driver'].split('.').first == 'vmwareapi'
  vmware_host_pass = get_password 'token', node['openstack']['compute']['vmware']['secret_name']
end

identity_admin_endpoint = admin_endpoint 'identity-admin'
auth_uri = auth_uri_transform identity_endpoint.to_s, node['openstack']['compute']['api']['auth']['version']
service_pass = get_password 'service', 'openstack-compute'
ironic_endpoint = internal_endpoint 'bare-metal-api'
ironic_admin_password = get_password 'service', 'openstack-bare-metal'

# Install z/VM driver for nova
node['ibm-openstack']['zvm-driver']['packages']['compute'].each do |pkg|
  package pkg do
    action :upgrade
  end
end

platform_options = node['openstack']['compute']['platform']
nova_user = node['openstack']['compute']['user']
nova_group = node['openstack']['compute']['group']

# Install nova compute packages
platform_options['compute_compute_packages'].each do |pkg|
  package pkg do
    options platform_options['package_overrides']
    action :upgrade
  end
end

service platform_options['compute_compute_service'] do
  action [:disable, :stop]
end

hosts.each do |host|
  compute_service_host = "#{platform_options['compute_compute_service']}-#{host}"
  zvm_xcat_password = get_user_password 'xcat', node['ibm-openstack']['zvm-driver'][host]['xcat']['server']
  zvm_image_default_password = get_user_password 'zlinuxroot', host

  # Create/Update service file openstack-nova-compute-<host> for each nova compute host
  template "/etc/init.d/#{compute_service_host}" do
    source 'service-openstack-nova-compute.erb'
    mode 00755
    action :create
    variables(
      host: host
    )
  end

  # Modify nova attributes by host
  ibm_openstack_zvm_driver_modify "nova-#{host}.conf" do
    host host
    action :modify_nova
  end

  # Create/Update nova-<host>.conf file for each nova compute host
  template "/etc/nova/nova-#{host}.conf" do
    source 'nova_zvm.conf.erb'
    mode 00640
    owner nova_user
    group nova_group
    action :create
    variables(
      sql_connection: sql_connection,
      novncproxy_base_url: novnc_endpoint.to_s,
      xvpvncproxy_base_url: xvpvnc_endpoint.to_s,
      xvpvncproxy_bind_host: xvpvnc_bind.host,
      xvpvncproxy_bind_port: xvpvnc_bind.port,
      novncproxy_bind_host: novnc_bind.host,
      novncproxy_bind_port: novnc_bind.port,
      vncserver_listen: vnc_bind.host,
      vncserver_proxyclient_address: vnc_proxy_bind.host,
      memcache_servers: memcache_servers,
      mq_service_type: mq_service_type,
      mq_password: mq_password,
      rabbit_hosts: rabbit_hosts,
      identity_endpoint: identity_endpoint,
      glance_api_scheme: image_endpoint.scheme,
      glance_api_ipaddress: image_endpoint.host,
      glance_api_port: image_endpoint.port,
      iscsi_helper: platform_options['iscsi_helper'],
      scheduler_default_filters: node['openstack']['compute']['scheduler']['default_filters'].join(','),
      osapi_compute_link_prefix: compute_api_endpoint.to_s,
      network_endpoint: network_endpoint,
      neutron_admin_password: neutron_admin_password,
      neutron_metadata_proxy_shared_secret: neutron_metadata_proxy_shared_secret,
      compute_api_bind_ip: compute_api_bind.host,
      compute_api_bind_port: compute_api_bind.port,
      compute_metadata_api_bind_ip: compute_metadata_api_bind.host,
      compute_metadata_api_bind_port: compute_metadata_api_bind.port,
      ec2_api_bind_ip: ec2_api_bind.host,
      ec2_api_bind_port: ec2_api_bind.port,
      vmware_host_pass: vmware_host_pass,
      auth_uri: auth_uri,
      identity_admin_endpoint: identity_admin_endpoint,
      ironic_endpoint: ironic_endpoint,
      ironic_admin_password: ironic_admin_password,
      service_pass: service_pass,
      host: host,
      zvm_xcat_password: zvm_xcat_password,
      zvm_image_default_password: zvm_image_default_password
    ) # TODO: All these variables need to be synchronized with community cookbook.
    notifies :restart, "service[#{compute_service_host}]", :delayed
  end
end

hosts.each do |host|
  # Enable service of each nova compute host
  compute_service_host = "#{platform_options['compute_compute_service']}-#{host}"

  service compute_service_host do
    supports status: true, restart: true
    subscribes :restart, resources("template[/etc/nova/nova-#{host}.conf]")
    action [:enable, :start]
  end
end

hosts.each do |host|
  # Set up no password ssh between nova and z/VM xCAT
  xcat_mn_pass = get_user_password 'xcatmnadmin', node['ibm-openstack']['zvm-driver'][host]['xcat']['server']

  ibm_openstack_zvm_driver_ssh 'no password ssh' do
    nova_user nova_user
    nova_group nova_group
    mnpass xcat_mn_pass
    host host
    action [:set_dir, :authorize]
  end
end

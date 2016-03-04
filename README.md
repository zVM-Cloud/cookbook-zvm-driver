openstack-zvm-driver Cookbook
=================================
This cookbook configures OpenStack z/VM driver(including compute z/VM driver and network z/VM agent) on controller node or seperate nodes on x86 Linux system, to enable z/VM cloud for OpenStack.  
It supports multi computes/neutron zvm agents in one host.  
This cookbook is for OpenStack Kilo version, we suggest deploy to z/VM CMA with cookbook-compute-anywhere and cookbook-external-keystone from Liberty.

Support Platform
--------
RHEL7 on x86

Requirements
------------
11.10.4 chef or higher required.

Cookbooks
---------

The following cookbooks are dependencies:

* openstack-common
* openstack-compute
* openstack-image
* openstack-network

Usage
-----

Here is a diagram of z/VM driver in the "Single Controller + N Compute" mode:  
|--------------|--------------------------------------------------------------|----------------------------------|  
| Services     |Controller Node                                               |Cloud Node x                      |  
|--------------|--------------------------------------------------------------|----------------------------------|  
| Compute      |nova-api, nova-cert, nova-conductor, nova-scheduler           |nova-compute(nova-zvm-virt-driver)|  
|--------------|--------------------------------------------------------------|----------------------------------|  
| Network      |neutron-server                                                |neutron-zvm-agent                 |  
|--------------|--------------------------------------------------------------|----------------------------------|  
| Block Storage|cinder-scheduler, cinder-api, cinder-volume                   |                                  |  
|--------------|--------------------------------------------------------------|----------------------------------|  

From Juno release, the z/VM driver cookbook supports multi computes/neutron zvm agents in one host. 
The releated data_bag also need to be changed. All the xCAT's passwords are in one data bag item.
The index "xcat_server" should be same with node['ibm-openstack']['zvm-driver'][host]['xcat']['server'].

An example of user_passwords/xcat.json:  
{  
  "id": "xcat",  
  "xcat": "admin",  
  "1.1.1.1": "admin",  
  "2.2.2.2": "admin"  
}

ibm-openstack-zvm-driver CHANGELOG
==================================

This file is used to list changes made in each version of the ibm-openstack-zvm-driver cookbook.

11.1.0
-----
- ShuoZhang - Remove include-recipe in neutron-server-configure recipe

11.0.9
-----
- ShuoZhang - Solve xCAT connection timeout

11.0.8
-----
- ShuoZhang - Remove redundant installation of openstack-neutron-openvswitch

11.0.7
-----
- ShuoZhang - Create openrc for compute node

11.0.6
-----
- ShuoZhang - Set the compute_monitors to []

11.0.5
-----
- ShuoZhang - Change the mode of /var/lib/nova same with community

11.0.4
-----
- ShuoZhang - Apply to all nodes, delete before force_override

11.0.3
-----
- ShuoZhang - Add neutron server configurations

11.0.2
-----
- ShuoZhang - Delete the openstack attributes before force_override

11.0.1
-----
- ShuoZhang - Update the service template file to make sure service can be started

11.0.0
-----
- ShuoZhang - Upgrade to Kilo level

10.2.2
-----
- ShuoZhang - Add glance_api_scheme variable as the nova.conf.erb changes

10.2.1
-----
- ShuoZhang - Fix incorrect attribute values

10.2.0
-----
- ShuoZhang - Support multi-service for nova and neutron in one compute node

10.1.2
-----
- HuangShiLin - Add chef provider for nova home undefine issue and judge for selinux state

10.1.1
-----
- ShuoZhang - Revert instance_name_template length to 8

10.1.0
-----
- ShuoZhang - Discard volume cookbook from Juno

10.0.0
-----
- ShuoZhang - Upgrade to Juno level

0.2.0
-----
- ShuoZhang - Allow xCAT user non-password ssh to nova compute

0.1.1
-----
- ShuoZhang - Add support for cinder

0.1.0
-----
- ShuoZhang - Initial release of ibm-openstack-zvm-driver

- - -
Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.

The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.

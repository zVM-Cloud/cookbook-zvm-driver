name             'ibm-openstack-zvm-driver'
maintainer       'IBM Corp.'
maintainer_email 'www.ibm.com'
license          'All rights reserved'
description      'Installs/Configures ibm-openstack-zvm-driver'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '11.1.0'

recipe 'ibm-openstack-zvm-driver::compute', 'Installs Nova driver for z/VM'
recipe 'ibm-openstack-zvm-driver::network-agent', 'Installs Neutron agent driver for z/VM'

supports 'redhat'

depends 'openstack-common', '~> 11.0'
depends 'openstack-identity', '~> 11.0'
depends 'openstack-image', '~> 11.0'
depends 'openstack-compute', '~> 11.0'
depends 'openstack-network', '~> 11.0'

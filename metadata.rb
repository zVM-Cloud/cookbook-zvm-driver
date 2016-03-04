name             'openstack-zvm-driver'
maintainer       'IBM Corp.'
maintainer_email 'https://github.com/zVM-Cloud'
license          'Apache 2.0'
description      'Installs/Configures openstack-zvm-driver'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '11.1.0'

recipe 'openstack-zvm-driver::compute', 'Installs Nova driver for z/VM'
recipe 'openstack-zvm-driver::network-agent', 'Installs Neutron agent driver for z/VM'

supports 'redhat'

depends 'openstack-common', '~> 11.0'
depends 'openstack-identity', '~> 11.0'
depends 'openstack-image', '~> 11.0'
depends 'openstack-compute', '~> 11.0'
depends 'openstack-network', '~> 11.0'

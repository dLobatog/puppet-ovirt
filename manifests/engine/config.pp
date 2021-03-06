# == Class: ovirt::engine::config
#
# The ovirt::engine::config class configures oVirt Engine.
#
# === Parameters
#
# [*url*]
#   This setting can be used to override the defualt localhost url to connect ovirt API
#
# [*username*]
#   This setting can be used to override the default admin username
#
# [*password*]
#   This setting can be used to override the default admin passowrd for ovirt
#
# [*dc_name*]
#   This setting can be used to override the default datacenter name (and create a new datacenter)
#
# [*cluster_name*]
#   This setting can be used to override the default cluster name (and create a new cluster)
#
# [*cpu_type*]
#   This setting can be used to override the default cluster cpu type
#
# [*host_name*]
#   This setting can be used to override the default hypervisor name (and create a new hypervisor)
#
# [*host_address*]
#   This setting can be used to override the default hypervisor (for installtion address)
#
# [*root_password*]
#   This setting can be used to override the default hypervisor root password
#
# [*storage_name*]
#   This setting can be used to override the default storage server name
#
# [*storage_type*]
#   This setting can be used to override the default storage type
#
# [*storage_address*]
#   This setting can be used to override the default storage server address
#
# [*storage_path*]
#   This setting can be used to override the default storage server path
#
# [*export_name*]
#   This setting can be used to override the default export domain name
#
# [*export_address*]
#   This setting can be used to override the default export domain address
#
# [*export_path*]
#   This setting can be used to override the default export domain path
# === Examples
#
#  class { ovirt::engine:
#    application_mode => 'ovirt',
#    storage_type    => 'fc',
#    organization    => 'example.com',
#  }
class ovirt::engine::config(

	$url =           'https://localhost:443',
	$username =      'admin@internal',
	$password =      'changeme',
	$dc_name =       'Default',
	$cluster_name =  'Default',
	$cpu_type =      'Intel Nehalem Family',
	$host_name =     'my_host',
	$host_address =  'host.fqdn',
	$root_password = 'changeme',
	$storage_name =  'my_storage',
	$storage_address = 'ip.address',
	$storage_path = '/path/to/share',
	$export_address = 'ip.address',
	$export_name =   'my_export',
	$export_path = '/pass/to/share',
	$storage_type =  'nfs',
) {
	require ovirt::engine::setup
	
	$config_file='/var/lib/ovirt-engine/setup/engine-DC-config.py'

	file { $config_file:
		owner   => 'root',
		group   => 'root',
		mode    => '0644',
		require => Service['ovirt-engine'],
		content => template('ovirt/dc_config.erb'),
		}
	notice ("configuration script added on \$config_file")

	notify {"oVirt Configuration stage- Done":}
	exec { 'engine_dc_config':
		require     => [
		  Service['ovirt-engine'],
		  File[$config_file],
		],
#		onlyif => "test ${healthy} = true",
#		refreshonly => true,
		path        => '/usr/bin/:/bin/:/sbin:/usr/sbin',
		command     => "python ${config_file}",
		logoutput => true,#"on_failure",
		timeout     => 1800,
		tries => 5,
		try_sleep => 10,
		}
}


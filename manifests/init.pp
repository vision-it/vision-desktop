# Class: vision_desktop
# ===========================
#
# Parameters
# ----------
#
# @param authorized_keys Authorized SSH keys
#
# Examples
# --------
#
# @example
# contain ::vision_desktop
#

class vision_desktop (

  Hash $authorized_keys,
  Hash $monitor_setup,
  Hash $packages = {},

) {

  # Base Configuration
  contain ::apt
  contain ::docker

  # Puppet Configuration
  contain vision_desktop::puppet

  contain vision_desktop::idm
  contain vision_desktop::nfs
  contain vision_desktop::editors::phpstorm

  # Local directory for personal files
  file { '/local':
    ensure => directory,
    group  => 'vision-it',
    mode   => '0775',
  }

  # Packages to install
  $package_default = {
    ensure   => present,
    provider => apt,
  }

  create_resources('package', $packages, $package_default)

  # SSH Config
  # Default values for any ssh_authorized_key
  $key_defaults = {
    ensure => present,
    user   => 'root',
  }

  create_resources('ssh_authorized_key', $authorized_keys, $key_defaults)

  package {['openssh-client', 'openssh-server']:
    ensure => present,
  }

  file { '/etc/ssh/sshd_config':
    ensure  => present,
    mode    => '0644',
    content => file('vision_desktop/sshd_config'),
    require => Package['openssh-server'],
    notify  => Service['ssh'],
  }

  service { 'ssh':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => File['/etc/ssh/sshd_config'],
  }

  # Monitor/Resolution Config
  file { '/usr/local/bin/xrandr.sh':
    ensure  => present,
    content => template('vision_desktop/xrandr.sh.erb'),
    mode    => '0775',
    owner   => 'root',
  }

}

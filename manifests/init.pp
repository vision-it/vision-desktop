# Class: vision_desktop
# ===========================
#
# Parameters
# ----------
#
# Examples
# --------
#
# @example
# contain ::vision_desktop
#

class vision_desktop (

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
    ensure  => directory,
  }

  # SSH Config
  # TODO: SSH Keys
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

}

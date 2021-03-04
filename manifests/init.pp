# Class: vision_desktop
# ===========================
#
# Parameters
# ----------
#
# @param authorized_keys Authorized SSH keys
# @param monitor_setup xrandr monitoring setup script
# @param packages Packages to install

#
# Examples
# --------
#
# @example
# contain ::vision_desktop
#

class vision_desktop (

  Hash $users,
  Hash $authorized_keys,
  Hash $monitor_setup,
  String $mail,
  Hash $packages = {},

) {

  # Base Configuration
  contain ::apt
  contain ::docker

  # Puppet Configuration
  contain vision_desktop::puppet

  contain vision_desktop::idm
  contain vision_desktop::editors::phpstorm

  # Default Shell Config
  file { '/etc/profile.d/vision_defaults.sh':
    ensure  => present,
    mode    => '0644',
    content => file('vision_desktop/profile.defaults.sh'),
  }

  # Default values for any user
  $user_defaults = {
    ensure     => present,
    managehome => true,
    groups     => [
      'sudo',
      'adm',
      'docker',
    ]
  }
  create_resources(user, $users, $user_defaults)

  # Packages to install
  $package_default = {
    ensure   => present,
    provider => apt,
  }
  create_resources('package', $packages, $package_default)

  # SSH Config
  $key_defaults = {
    ensure => present,
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

  class { 'unattended_upgrades':
    install_on_shutdown    => true,
    mail                   => { 'to'            => $mail,
                                'only_on_error' => true,

    },
    remove_new_unused_deps => true,
  }

}

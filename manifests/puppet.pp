# Class: vision_desktop::puppet
# ===========================
#
# Manages Puppet and its configuration
#
# Parameters
# ----------
#
# Examples
# --------
#
# @example
# contain ::vision_desktop::puppet
#

class vision_desktop::puppet (

  String $environment,
  String $repo_key,
  String $repo_key_id,
  String $control_repo_url,

) {

  # Adding the Puppet Repo to get the newest version
  apt::source { 'puppetlabs':
    location => 'https://apt.puppetlabs.com',
    repos    => 'puppet6',
    key      => {
      id      => $repo_key_id,
      content => $repo_key,
    },
    include  => {
      'src' => false,
      'deb' => true,
    },
    notify   => Exec['apt_update']
  }

  package { 'puppet-agent':
    ensure  => present,
    require => Apt::Source['puppetlabs'],
  }

  file { '/etc/puppetlabs/puppet/hiera.yaml':
    ensure  => present,
    mode    => '0644',
    content => file('vision_desktop/hiera.yaml'),
    require => Package['puppet-agent'],
  }

  file { '/etc/puppetlabs/puppet/puppet.conf':
    ensure  => present,
    mode    => '0644',
    content => template('vision_desktop/puppet.conf.erb'),
    require => Package['puppet-agent'],
  }

  file { '/etc/puppetlabs/puppet/site.pp':
    ensure  => present,
    mode    => '0644',
    content => file('vision_desktop/site.pp'),
    require => Package['puppet-agent'],
  }

  # g10k Configuration
  # TODO: manage g10k download
  file { '/etc/g10k/':
    ensure  => directory,
  }

  file { '/etc/g10k/g10k.yaml':
    ensure  => present,
    mode    => '0644',
    content => template('vision_desktop/g10k.yaml.erb'),
    require => File['/etc/g10k'],
  }

  # Puppet apply Service and Timer
  # Since we use a masterless setup
  file { '/etc/systemd/system/deploy.service':
    ensure  => present,
    content => file('vision_desktop/deploy.service'),
  }

  file { '/etc/systemd/system/apply.service':
    ensure  => present,
    content => file('vision_desktop/apply.service'),
    require => File['/etc/systemd/system/deploy.service'],
    notify  => Service['apply'],
  }

  file { '/etc/systemd/system/apply.timer':
    ensure  => present,
    content => file('vision_desktop/apply.timer'),
    notify  => Service['apply'],
  }

  service { 'apply':
    ensure   => running,
    enable   => true,
    provider => 'systemd',
    name     => 'apply.timer',
    require  => [
      File['/etc/systemd/system/apply.service'],
      File['/etc/systemd/system/apply.timer'],
    ],
  }

}

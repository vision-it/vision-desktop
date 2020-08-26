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

) {

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

  # TODO: Puppet Apply Timer

}

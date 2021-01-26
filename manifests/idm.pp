# Class: vision_desktop::idm
# ===========================
#
# Parameters
# ----------
# @param ldap_base LDAP search base
# @param ldap_server URI of LDAP Server (will be prefixed by ldaps://)
#
# @example
# contain ::vision_idm
#

class vision_desktop::idm (

  String $ldap_base,
  String $ldap_server,

) {

  # LDAP Configuration
  package { ['ldap-utils', 'libpam-ldap', 'libnss-ldap', 'nscd']:
    ensure   => present,
  }

  file { '/etc/ldap/ldap.conf':
    ensure  => present,
    content => template('vision_desktop/idm/ldap.conf.erb'),
  }

  file { '/etc/nsswitch.conf':
    ensure  => present,
    content => file('vision_desktop/idm/nsswitch.conf'),
  }

  service { 'nscd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/ldap/ldap.conf'],
    subscribe  => File['/etc/ldap/ldap.conf'],
  }
}

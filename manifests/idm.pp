# Class: vision_desktop::idm
# ===========================
#
# Parameters
# ----------
# @param kdcs List of Kerberos servers in Realm
# @param admin_kdc Kerberos Admin server
# @param ldap_base LDAP search base
# @param ldap_server URI of LDAP Server (will be prefixed by ldaps://)
# @param realm Name of Kerberos Realm
# @param keytab_content Content of the client's Keytab
#
# @example
# contain ::vision_idm
#

class vision_desktop::idm (

  Array[String] $kdcs,
  String $admin_kdc,
  String $ldap_base,
  String $ldap_server,
  String $realm,
  String $keytab_content

) {

  # Kerberos Configuration

  package { [
    'krb5-config',
    'krb5-user',
    'libpam-krb5',
  ]:
    ensure   => present,
  }

  file { '/etc/krb5.conf':
    ensure  => present,
    content => template('vision_desktop/idm/krb5.conf.erb'),
    require => Package['krb5-config'],
  }

  file { '/etc/krb5.keytab':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $keytab_content,
  }

  # LDAP Configuration

  package { [
    'nslcd-utils',
    'nslcd',
  ]:
    ensure => present,
  }

  package { 'libnss-ldapd':
    ensure       => present,
    require      => File['/var/cache/libnss-ldapd.preseed'],
    responsefile => '/var/cache/libnss-ldapd.preseed',
  }

  file { '/var/cache/libnss-ldapd.preseed':
    ensure  => present,
    content => file('vision_desktop/idm/libnss-ldapd.preseed'),
    mode    => '0600',
    backup  => false,
  }

  file { '/etc/idmapd.conf':
    ensure  => present,
    content => file('vision_desktop/idm/idmapd.conf'),
  }

  file { '/etc/nsswitch.conf':
    ensure  => present,
    content => file('vision_desktop/idm/nsswitch.conf'),
  }

  file { '/etc/nslcd.conf':
    ensure  => present,
    content => template('vision_desktop/idm/nslcd.conf.erb'),
    require => Package['nslcd'],
    notify  => Service['nslcd'],
  }

  service { 'nslcd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/nslcd.conf'],
  }

}

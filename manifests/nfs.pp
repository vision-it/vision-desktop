# Class: vision_desktop::nfs
# ===========================
#
# Parameters
# ----------
#
# @param home_source Source for /home
# @param home_destination Destination for mount
# @param it_source Source for /itshare
# @param it_destination Destination for mount
#
# @example
# contain ::vision_nfs
#

class vision_desktop::nfs (

  String $homes_source,
  String $homes_destination,
  String $it_source,
  String $it_destination,

) {

  package { 'nfs-common':
    ensure => present,
  }

  file { $it_destination:
    ensure  => directory,
    require => Package['nfs-common'],
  }

  file { $homes_destination:
    ensure  => directory,
    require => Package['nfs-common'],
  }

  # NFS Client config for Kerberos/idmapd
  # See vision_kerberos for idmap.conf
  file { '/etc/default/nfs-common':
    ensure  => present,
    content => file('vision_desktop/nfs-common'),
    require => Package['nfs-common'],
  }

  # Add NFS shares to fstab config
  # Destination is defined in Hiera
  # _netdev mount options prevents system from attempting to mount until network is up
  # x-systemd.automount automatically mounts the remote fs on startup
  file_line { 'fstab_homes':
    ensure  => present,
    path    => '/etc/fstab',
    line    => "${homes_source} ${homes_destination} nfs4 vers=4,sec=krb5p,_netdev,x-systemd.automount 0 0",
    match   => ".*${homes_destination}.*nfs4.*sec=krb5p.*0.*0",
    replace => true,
    require => File[$homes_destination],
  }

  file_line { 'fstab_projit':
    ensure  => present,
    path    => '/etc/fstab',
    line    => "${it_source} ${it_destination} nfs4 vers=4,sec=krb5p,_netdev,x-systemd.automount 0 0",
    match   => ".*${it_destination}.*nfs4.*sec=krb5p.*0.*0",
    replace => true,
    require => File[$it_destination],
  }

}

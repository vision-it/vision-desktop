# Class: vision_desktop::editors:phpstorm
# ===========================
#
# Install PhpStorm IDE y downloading tarball and unpack it
#
# Parameters
# ----------
#
# @param base_url Base URL to download tarball
# @param version PHPStorm Version
# @param install_target Path to extract tarball to
#

class vision_desktop::editors::phpstorm (

  String  $base_url,
  String  $version,
  String  $install_target,

){

  $url      = "${base_url}PhpStorm-${version}.tar.gz"
  $filename = "${install_target}/PhpStorm-${version}.tar.gz"

  archive { $filename:
    ensure          => present,
    source          => $url,
    checksum_verify => false,
    extract         => true,
    extract_command => "mkdir ${install_target}/phpstorm-${version} && tar xfz %s --strip-components=1 -C ${install_target}/phpstorm-${version}/ && chown -R root:root ${install_target}/phpstorm-${version}", # lint:ignore:140chars
    extract_path    => $install_target,
  }

  file { "${install_target}/phpstorm":
    ensure    => link,
    target    => "${install_target}/phpstorm-${version}",
    subscribe => Archive[$filename],
  }

  file { '/usr/local/bin/phpstorm':
    ensure    => link,
    target    => "${install_target}/phpstorm/bin/phpstorm.sh",
    subscribe => Archive[$filename],
  }

}

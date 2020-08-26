# This file is managed by Puppet
node default {

  if $facts['role'] {
    $role = $::role
  } else {
    $role = 'default'
  }

  contain "vision_roles::${role}"
}

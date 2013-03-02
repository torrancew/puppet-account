# == Define: Account
#
# A defined type for managing user accounts
# Features:
#   * Account creation
#   * Setting the login shell
#   * Group creation (optional)
#   * Home directory creation ( and optionally management via /etc/skel )
#   * Support for system users/groups
#   * SSH key management (optional)
#
# === Parameters
#
# [*username*]
#   The name of the user to be created.
#   Defaults to the title of the account resource.
#
# [*password*]
#   The password to set for the user.
#   The default is to disable the password.
#
# [*shell*]
#   The user's default login shell.
#   The default is '/bin/bash'
#
# [*manage_home*]
#   Whether the underlying user resource should manage the home directory.
#   This setting only determines whether or not puppet will copy /etc/skel.
#   Regardless of its value, at minimum, a home directory and a $HOME/.ssh
#   directory will be created. Defaults to true.
#
# [*home_dir*]
#   The location of the user's home directory.
#   Defaults to "/home/$title".
#
# [*create_group*]
#   Whether or not a dedicated group should be created for this user.
#   If set, a group with the same name as the user will be created.
#   Otherwise, the user's primary group will be set to "users".
#   Defaults to true.
#
# [*groups*]
#   An array of additional groups to add the user to.
#   Defaults to an empty array.
#
# [*system*]
#   Whether the user is a "system" user or not.
#   Defaults to false.
#
# [*ssh_key*]
#   A string containing a public key suitable for SSH logins
#   If set to 'undef', no key will be created.
#   Defaults to undef.
#
# [*ssh_key_type*]
#   The type of SSH key to manage. Accepts any value accepted by
#   the ssh_authorized_key's 'type' parameter.
#   Defaults to 'ssh-rsa'.
#
# === Examples
#
#  account { 'sysadmin':
#    home_dir => '/opt/home/sysadmin',
#    groups   => [ 'sudo', 'wheel' ],
#  }
#
# === Authors
#
# Tray Torrance <devwork@warrentorrance.com>
#
# === Copyright
#
# Copyright 2013 Tray Torrance, unless otherwise noted
#
define account(
  $username = $title, $password = '!', $shell = '/bin/bash', $manage_home = true,
  $home_dir = "/home/${title}", $create_group = true, $system = false,
  $ssh_key = undef, $ssh_key_type = 'ssh-rsa', $groups = []
) {

  if $create_group == true {
    $primary_group = $username
    group {
      $title:
        ensure => present,
        name   => $username,
        system => $system,
        before => User[$title],
    }
  }

  else {
    $primary_group = 'users'
  }

  user {
    $title:
      ensure     => present,
      name       => $username,
      password   => $password,
      shell      => $shell,
      gid        => $primary_group,
      groups     => $groups,
      home       => $home_dir,
      managehome => $manage_home,
      system     => $system,
  }

  file {
    "${title}_home":
      ensure  => directory,
      path    => $home_dir,
      owner   => $username,
      group   => $primary_group,
      mode    => 0750,
      require => User[$title];

    "${title}_sshdir":
      ensure  => directory,
      path    => "${home_dir}/.ssh",
      owner   => $username,
      group   => $primary_group,
      mode    => 0700,
      require => File["${title}_home"];
  }

  if $ssh_key != undef {
    ssh_authorized_key {
      $title:
        ensure  => present,
        type    => $ssh_key_type,
        name    => "${title} SSH Key",
        user    => $username,
        key     => $ssh_key,
        require => File["${title}_sshdir"];
    }
  }
}


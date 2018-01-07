# == Define: Account
#
# A defined type for managing user accounts
# Features:
#   * Account creation w/ UID control
#   * Setting the login shell
#   * Group creation w/ GID control (optional)
#   * Home directory creation ( and optionally management via /etc/skel )
#   * Support for system users/groups
#   * SSH key management (optional)
#
# === Parameters
#
# [*ensure*]
#   The state at which to maintain the user account.
#   Can be one of "present" or "absent".
#   Defaults to present.
#
# [*username*]
#   The name of the user to be created.
#   Defaults to the title of the account resource.
#
# [*uid*]
#   The UID to set for the new account.
#   If set to undef, this will be auto-generated.
#   Defaults to undef.
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
# [*home_dir_perms*]
#   The permissions set on the home directory.
#   Defaults to 0750
#
# [*create_group*]
#   Whether or not a dedicated group should be created for this user.
#   If set, a group with the same name as the user will be created.
#   Otherwise, the user's primary group will be set to "users".
#   Defaults to true.
#
# [*purge*]
#   Whether the user's home and ssh directories should be forcibly removed
#   when set to absent
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
# [*comment*]
#   Sets comment metadata for the user
#
# [*gid*]
#   Sets the primary group of this user, if $create_group = false
#   Defaults to 'users'
#     WARNING: Has no effect if used with $create_group = true
#
# [*allowdupe*]
#   Whether to allow duplicate UIDs.
#   Defaults to false.
#   Valid values are true, false, yes, no.
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
  String $username                        = $title,
  String $password                        = '!',
  String $shell                           = '/bin/bash',
  Boolean $manage_home                    = true,
  Optional[Account::Path] $home_dir       = undef,
  String $home_dir_perms                  = '0750',
  Boolean $create_group                   = true,
  Boolean $system                         = false,
  Optional[Integer] $uid                  = undef,
  Optional[String] $ssh_key               = undef,
  String $ssh_key_type                    = 'ssh-rsa',
  Array[Variant[Integer, String]] $groups = [],
  Enum[present, absent] $ensure           = present,
  Boolean $purge                          = false,
  String $comment                         = "${title} Puppet-managed User",
  Variant[Integer, String] $gid           = 'users',
  Boolean $allowdupe                      = false
) {

  if $home_dir == undef {
    if $username == 'root' {
      case $::facts['operatingsystem'] {
        'Solaris': { $home_dir_real = '/' }
        default:   { $home_dir_real = '/root' }
      }
    }
    else {
      case $::facts['operatingsystem'] {
        'Solaris': { $home_dir_real = "/export/home/${username}" }
        default:   { $home_dir_real = "/home/${username}" }
      }
    }
  }
  else {
      $home_dir_real = $home_dir
  }

  if $create_group == true {
    $primary_group = $username

    group {
      $title:
        ensure => $ensure,
        name   => $username,
        system => $system,
        gid    => $uid,
    }

    if $ensure == 'present' {
      Group[$title] -> User[$title]
    } else {
      User[$title] -> Group[$title]
    }
  }
  else {
    $primary_group = $gid
  }


  if $ensure == 'present' {
    $dir_ensure = directory
    $dir_owner  = $username
    $dir_group  = $primary_group
    User[$title] -> File["${title}_home"] -> File["${title}_sshdir"]
  } else {
    $dir_ensure = absent
    $dir_owner  = undef
    $dir_group  = undef
    File["${title}_sshdir"] -> File["${title}_home"] -> User[$title]
  }

  user {
    $title:
      ensure     => $ensure,
      name       => $username,
      comment    => $comment,
      uid        => $uid,
      password   => $password,
      shell      => $shell,
      gid        => $primary_group,
      groups     => $groups,
      home       => $home_dir_real,
      managehome => $manage_home,
      system     => $system,
      allowdupe  => $allowdupe,
  }

  file {
    "${title}_home":
      ensure => $dir_ensure,
      path   => $home_dir_real,
      owner  => $dir_owner,
      group  => $dir_group,
      force  => $purge,
      mode   => $home_dir_perms;

    "${title}_sshdir":
      ensure => $dir_ensure,
      path   => "${home_dir_real}/.ssh",
      owner  => $dir_owner,
      group  => $dir_group,
      force  => $purge,
      mode   => '0700';
  }

  if $ssh_key != undef {
    File["${title}_sshdir"]
    -> ssh_authorized_key {
      $title:
        ensure => $ensure,
        type   => $ssh_key_type,
        name   => "${title} SSH Key",
        user   => $username,
        key    => $ssh_key,
    }
  }
}


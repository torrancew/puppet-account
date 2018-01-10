# A defined type for managing user accounts and (optionally) SSH authorized keys & group membership.
#
# @example Default usage
#     account { 'sysadmin': }
#
# @example Advanced usage
#     account { 'sysadmin':
#       password => '$6$abcdef$ghijklmnopqrstuvwxyz',
#       shell    => '/bin/zsh',
#       uid      => 1000,
#       ssh_keys => {
#         yubikey => {
#           key  => 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789==',
#           type => 'ssh-rsa',
#       },
#     }
#
# @param ensure The state in which to maintain the user account.
# @param username The name of the user to be created.
# @param allowdupe Whether to allow duplicate UIDs.
# @param comment Sets comment metadata for the user.
# @param create_group Whether or not a dedicated group should be created for this user.
#                     If set, a group with the same name as the user will be created.
#                     Otherwise, the user's primary group will be set to "users".
# @param home_dir The location of the user's home directory.
# @param home_dir_perms The permissions set on the home directory.
# @param gid Sets the primary group of this user, if create_group is false.
#            WARNING: Has no effect if used with $create_group = true
# @param groups An array of additional groups to add the user to.
# @param manage_home Whether the underlying user resource should manage the home directory.
#                    This setting only determines whether or not puppet will copy /etc/skel.
#                    Regardless of its value, at minimum, a home directory and a ~/.ssh directory will be created
# @param password The password to set for the user.
# @param purge Whether the user's home and ssh directories should be forcibly removed when ensure is absent.
# @param shell The user's default login shell.
# @param ssh_keys A hash of Account::Sshkey structs containing one or more public key suitable for SSH logins.
# @param system Whether the user is a "system" user or not.
# @param uid The UID to set for the new account. If set to undef, this will be auto-generated.
#
# @author Tray Torrance <torrancew@gmail.com>
#
define account(
  Enum[present, absent] $ensure           = present,
  String $username                        = $title,
  Boolean $allowdupe                      = false,
  String $comment                         = "${title} Puppet-managed User",
  Boolean $create_group                   = true,
  Variant[Integer, String] $gid           = 'users',
  Array[Variant[Integer, String]] $groups = [],
  Optional[Account::Path] $home_dir       = undef,
  String $home_dir_perms                  = '0750',
  Boolean $manage_home                    = true,
  String $password                        = '!',
  Boolean $purge                          = false,
  String $shell                           = '/bin/bash',
  Hash[String, Account::Sshkey] $ssh_keys = {},
  Boolean $system                         = false,
  Optional[Integer] $uid                  = undef,
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
  } else {
    $home_dir_real = $home_dir
  }

  if $create_group == true {
    $primary_group = $username

    group { $title:
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

  user { $title:
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

  file { "${title}_home":
    ensure => $dir_ensure,
    path   => $home_dir_real,
    owner  => $dir_owner,
    group  => $dir_group,
    force  => $purge,
    mode   => $home_dir_perms,
  }

  file { "${title}_sshdir":
    ensure => $dir_ensure,
    path   => "${home_dir_real}/.ssh",
    owner  => $dir_owner,
    group  => $dir_group,
    force  => $purge,
    mode   => '0700',
  }

  $ssh_keys.each |$key_id, $key_data| {
    ssh_authorized_key { "${title}_${key_id}":
      ensure => $ensure,
      user   => $username,
      *      => $key_data,
    }

    if $ensure == 'present' {
      File["${title}_sshdir"] -> Ssh_authorized_key["${title}_${key_id}"]
    } else {
      Ssh_authorized_key["${title}_${key_id}"] -> File["${title}_sshdir"]
    }
  }
}


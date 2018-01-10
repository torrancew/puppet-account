# Puppet Account Module

[![master branch status](https://secure.travis-ci.org/torrancew/puppet-account.png?branch=master)](http://travis-ci.org/torrancew/puppet-account)

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with account](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Module Description

The account module eases the creation of UNIX user accounts.

Features:

  * Creation/Removal of accounts (via the `ensure` parameter)
  * Account creation w/UID control
  * Setting the login shell
  * Dedicated Group creation w/GID control (optional)
  * Home directory creation (and optionally management via `/etc/skel`)
  * Support for system users
  * SSH key management (optional)

## Setup

This module has no specific dependencies, as it merely wraps several common native Puppet types in some logic.

## Usage

Standard usage of this module would probably look something like this:

    account { 'sysadmin':
      home_dir => '/opt/sysadmin',
      groups   => [ 'sudo', 'users' ],
      comment   => 'SysAdmin user',
      ssh_keys => {
        'some_key_comment' => {
          type => 'ssh-rsa',
          key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEArfQmMkvtWRnwas3DIti9qAuSFQXKcE0kdp5f42PP8l2kTytJPPWp5T/q8PXDQ2d2X5KplMCMDiUQkchqhmDp840jsqBQ9iZPejAjv3w2kITgScFNymAcErtzX52iw4lnUyjZzomCW8G3YthQMaRm2NkI4wcVcjzq+SKyTfzrBoH21RgZlfcx+/50AFRrarpYqel9W5DuLmmShHxD8clPS532Z/1X+1jCW2KikUhdo98lxYTIgFno05lwFOS9Ry89UyBarn1Ecp1zXpIBE7dMQif3UyLUTU9zCVIoZiJj4iO5lemSSV0v8GL97qclBUVJpaCpc4ebR7bhi0nQ28RcxQ==',
        },
      },
    }

The type can also be virtualized and realized later (see the [official documentation](http://docs.puppetlabs.com/guides/virtual_resources.html) for more information on this pattern):

    @account { 'sysadmin': groups  => [ 'sudo', 'users' ] }

There is no implicit Hiera support in this module. For defining accounts via
Hiera data, it is recommended to use the `profile` portion of the
`role/profile` pattern.

## Reference

For the detailed reference, see the inline docs:

    $ bundle exec rake doc

## Limitations

* Does **not** automatically create arbitrary extra groups. Use the native group type for this.

## Development

Please use the github issues functionality to report any bugs or requests for new features.
Feel free to fork and submit pull requests for potential contributions.

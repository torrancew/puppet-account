# Puppet Account Module

A puppet module designed to ease the management of user accounts.

Features:

  * Creation/Removal of accounts (via the `ensure` parameter)
  * Account creation w/UID control
  * Setting the login shell
  * Dedicated Group creation w/GID control (optional)
  * Home directory creation (and optionally management via `/etc/skel`)
  * Support for system users
  * SSH key management (optional)

Limitations:

  * Does **not** automatically create arbitrary extra groups. Use the native group type for this.

## Build Status

[![master branch status](https://secure.travis-ci.org/torrancew/puppet-account.png?branch=master)](http://travis-ci.org/torrancew/puppet-account)

## Documentation

A brief usage summary with examples follows.
For full documentation of all parameters, see the inline puppet docs:

    $ puppet doc manifests/init.pp

## Usage

### account

Standard usage of this defined type would probably look something like this:

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

For use with [hiera](http://docs.puppetlabs.com/#hierahiera1), one could define a nested hash of account resources in a hiera data file (this example assumes you use YAML):

    ---
    accounts:
      sysadmin:
        home_dir: /opt/sysadmin
        groups:
          - sudo
          - users
          ssh_keys:
            some_key_comment:
              type: ssh-rsa
              key: AAAAB3NzaC1yc2EAAAABIwAAAQEArfQmMkvtWRnwas3DIti9qAuSFQXKcE0kdp5f42PP8l2kTytJPPWp5T/q8PXDQ2d2X5KplMCMDiUQkchqhmDp840jsqBQ9iZPejAjv3w2kITgScFNymAcErtzX52iw4lnUyjZzomCW8G3YthQMaRm2NkI4wcVcjzq+SKyTfzrBoH21RgZlfcx+/50AFRrarpYqel9W5DuLmmShHxD8clPS532Z/1X+1jCW2KikUhdo98lxYTIgFno05lwFOS9Ry89UyBarn1Ecp1zXpIBE7dMQif3UyLUTU9zCVIoZiJj4iO5lemSSV0v8GL97qclBUVJpaCpc4ebR7bhi0nQ28RcxQ==
      appadmin:
        home_dir: /opt/appadmin
        groups:
          - users

And then use the [create_resources function](http://docs.puppetlabs.com/references/latest/function.html#createresources) in a puppet manifest:

    $accounts = hiera_hash('accounts')
    create_resources('account', $accounts)

## Feedback

Please use the github issues functionality to report any bugs or requests for new features.

## Contribution

Feel free to fork and submit pull requests for potential contributions.

## ToDo

  - <del>Unit Tests</del>
  - <del>Submit module to PuppetForge</del>
  - <del>Support for removing accounts</del>
  - <del>Support for multiple SSH keys</del>
  * <del>Acceptance Tests</del>


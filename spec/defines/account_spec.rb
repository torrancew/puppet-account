require 'spec_helper'

describe 'account' do
  describe 'account with default values' do
    let( :title ) { 'user' }

    it do
      should contain_group( title ).with({
        'ensure' => 'present',
        'name'   => title,
        'system' => false,
        'gid'    => nil,
        'before' => "User[#{title}]",
      })
    end

    it do
      should contain_user( title ).with({
        'ensure'     => 'present',
        'name'       => title,
        'uid'        => nil,
        'password'   => '!',
        'shell'      => '/bin/bash',
        'gid'        => title,
        'groups'     => [],
        'home'       => "/home/#{title}",
        'managehome' => true,
        'system'     => false,
        'before'     => "File[#{title}_home]",
      })
    end

    it do
      should contain_file( "#{title}_home" ).with({
        'ensure'  => 'directory',
        'path'    => "/home/#{title}",
        'owner'   => title,
        'group'   => title,
        'mode'    => '0750',
        'before'  => "File[#{title}_sshdir]",
      })
    end

    it do
      should contain_file( "#{title}_sshdir" ).with({
        'ensure'  => 'directory',
        'path'    => "/home/#{title}/.ssh",
        'owner'   => title,
        'group'   => title,
        'mode'    => '0700',
      })
    end
  end

  describe 'account with custom values' do
    let( :title ) { 'admin' }
    let( :params ) {{
      :username    => 'sysadmin',
      :shell       => '/bin/zsh',
      :manage_home => false,
      :home_dir    => '/opt/admin',
      :system      => true,
      :uid         => 777,
      :groups      => [ 'sudo', 'users' ],
    }}

    it do
      should contain_group( title ).with({
        'name'   => params[:username],
        'system' => true,
        'gid'    => params[:uid],
      })
    end

    it do
      should contain_user( title ).with({
        'name'        => params[:username],
        'uid'         => params[:uid],
        'shell'       => params[:shell],
        'gid'         => params[:username],
        'groups'      => params[:groups],
        'home'        => params[:home_dir],
        'manage_home' => params[:manage_home] == false ? nil : true,
        'system'      => params[:system],
      })
    end

    it do
      should contain_file( "#{title}_home" ).with({
        'path'  => params[:home_dir],
        'owner' => params[:username],
        'group' => params[:username],
      })
    end

    it do 
      should contain_file( "#{title}_sshdir" ).with({
        'path' => "#{params[:home_dir]}/.ssh",
        'owner' => params[:username],
        'group' => params[:username],
      })
    end
  end

  describe 'account with no dedicated group' do
    let( :title ) { 'user' }
    let( :params ) {{ :create_group => false }}

    it do
      should_not contain_group( title )
    end

    it do
      should contain_user( title ).with({ 'gid' => 'users' })
    end

    it do
      should contain_file( "#{title}_home" ).with({ 'group' => 'users' })
    end

    it do
      should contain_file( "#{title}_sshdir" ).with({ 'group' => 'users' })
    end
  end

  describe 'account with no dedicated group' do
    let( :title ) { 'user' }
    let( :params ) {{ :create_group => false, :gid => 'staff' }}

    it do
      should_not contain_group( title )
    end

    it do
      should contain_user( title ).with({ 'gid' => params[:gid] })
    end

    it do
      should contain_file( "#{title}_home" ).with({ 'group' => params[:gid] })
    end

    it do
      should contain_file( "#{title}_sshdir" ).with({ 'group' => params[:gid] })
    end
  end
end


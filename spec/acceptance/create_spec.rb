require 'spec_helper_acceptance'

describe 'account defined type' do
  context 'default parameters' do
    let (:code) {
      <<-EOS
        account { 'default_user': }
      EOS
    }

    it 'should run without errors' do
      result = apply_manifest(code, :catch_failures => true)
      expect(result.exit_code).to eq 2
    end

    describe group('default_user') do
      it { should exist }
    end

    describe user('default_user') do
      it { should exist }
      it { should have_login_shell '/bin/bash' }
      it { should have_home_directory '/home/default_user' }
      it { should belong_to_primary_group 'default_user' }
    end
  end

  context 'with ssh key' do
    let (:code) {
      <<-EOS
        account { 'ssh_key_user':
          ssh_keys => {
            managed_key => {
              key  => 'abcdefghijklmnopqrstuvwxyz',
              type => 'ssh-rsa',
            },
          }
        }
      EOS
    }

    it 'should run without errors' do
      result = apply_manifest(code, :catch_failures => true)
      expect(result.exit_code).to eq 2
    end

    describe user('ssh_key_user') do
      it { should exist }
      it { should have_authorized_key 'ssh-rsa abcdefghijklmnopqrstuvwxyz ssh_key_user_managed_key' }
    end
  end

  context 'with multiple ssh keys' do
    let (:code) {
      <<-EOS
        account { 'multi_ssh_key_user':
          ssh_keys => {
            first_key  => {
              key  => 'abcdefghijklmnopqrstuvwxyz',
              type => 'ssh-rsa',
            },
            second_key => {
              key  => 'zyxwvutsrqponmlkjihgfedcba',
              type => 'ssh-rsa',
            },
          },
        }
      EOS
    }

    it 'should run without errors' do
      result = apply_manifest(code, :catch_failures => true)
      expect(result.exit_code).to eq 2
    end

    describe user('multi_ssh_key_user') do
      it { should exist }
      it { should have_authorized_key 'ssh-rsa abcdefghijklmnopqrstuvwxyz multi_ssh_key_user_first_key' }
      it { should have_authorized_key 'ssh-rsa zyxwvutsrqponmlkjihgfedcba multi_ssh_key_user_second_key' }
    end
  end
end

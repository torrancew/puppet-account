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
          ssh_key => 'abcdefghijklmnopqrstuvwxyz',
        }
      EOS
    }

    it 'should run without errors' do
      result = apply_manifest(code, :catch_failures => true)
      expect(result.exit_code).to eq 2
    end

    describe user('ssh_key_user') do
      it { should exist }
      it { should have_authorized_key 'ssh-rsa abcdefghijklmnopqrstuvwxyz ssh_key_user SSH Key' }
    end
  end
end

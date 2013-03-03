require 'spec_helper'

describe 'account defaults' do
  let( :title ) { 'user' }

  it do
    should contain_group( title ).with(
      'ensure' => 'present',
      'name'   => title,
      'system' => false,
      'gid'    => 'undef',
      'before' => "User['#{title}']",
    )

    should contain_user( title )
  end
end


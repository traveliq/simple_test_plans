require 'spec_helper'

describe User do
  fixtures :users
  before(:each) do
    @user = users(:tester)
  end

  it "has valid fixtures" do
    @user.should be_valid
  end

  it "is not valid without an email" do
    @user.email = nil
    @user.should_not be_valid
  end
end

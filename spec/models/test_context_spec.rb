require 'spec_helper'

describe TestContext do
  before(:each) do
    @valid_attributes = {
      :name => 'Deploy/Production'      
    }
  end

  it "should create a new instance given valid attributes" do
    TestContext.new(@valid_attributes).should be_valid
  end

  it "should not create a new instance given invalid attributes" do
    TestContext.new(:name => '').should_not be_valid
  end

  it "should have many test_runs" do
    tc = TestContext.create!(@valid_attributes)
    TestRun.create!(:test_context_id => tc.id,  :state => 'running')
    tc.test_runs.count.should == 1
    TestRun.create!(:test_context_id => tc.id,  :state => 'running')
    tc.test_runs.count.should == 2
  end

  it "should have many test_group_templates" do
    tc = TestContext.create!(@valid_attributes) 
    tgt_1 = TestGroupTemplate.create!(:name => 'Doorway')
    tgt_2 = TestGroupTemplate.create!(:name => 'FlightSearch')
    TestContexting.create!(:test_context_id => tc.id, :test_group_template_id => tgt_1.id)
    TestContexting.create!(:test_context_id => tc.id, :test_group_template_id => tgt_2.id)
    tc.test_group_templates.count.should == 2
  end
end

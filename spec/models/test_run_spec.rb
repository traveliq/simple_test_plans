require 'spec_helper'

describe TestRun do
  before(:each) do
    @test_context = test_contexts(:one)
  end

  it "should create a new instance given valid attributes" do
    TestRun.new(:test_context_id => @test_context.id, :state => 'running').should be_valid
  end

  it "should belongs to test_context " do
    tr = TestRun.create!(:test_context_id => @test_context.id, :state => 'running')
    tr.test_context.should == @test_context
  end

  it "should has many test_groups " do
    tr = TestRun.create!(:test_context_id => @test_context.id, :state => 'running')
    TestGroup.create!(:test_run_id => tr.id, :user_id => 1, :test_group_template_id => 1, :state => 'running')
    TestGroup.create!(:test_run_id => tr.id, :user_id => 1, :test_group_template_id => 2, :state => 'running')
    tr.test_groups.count.should == 2
  end

end

describe TestRun, 'AASM' do
  before(:each) do
    @test_context = test_contexts(:one)
    @test_run = TestRun.create!(:test_context_id => @test_context.id, :state => 'running')
    @test_group_1 = TestGroup.create!(:test_run_id => @test_run.id, :user_id => 1, :test_group_template_id => 1, :state => 'running')
    @test_group_2 = TestGroup.create!(:test_run_id => @test_run.id, :user_id => 1, :test_group_template_id => 2, :state => 'running')
  end

  it "should have correct state!" do
    @test_run.test_groups.running?.should == true
    @test_run.test_groups.done?.should == false
    
    @test_group_1.state = 'finished_with_failure'
    @test_group_1.save!
    @test_run.test_groups.finished_with_failure?.should == false

    @test_group_2.state = 'finished_with_success'
    @test_group_2.save!
    @test_run.test_groups.finished_with_failure?.should == true

    @test_group_1.state = 'finished_with_success'
    @test_group_1.save!
    @test_group_2.state = 'finished_with_success'
    @test_group_2.save!
    @test_run.test_groups.finished_with_success?.should == true
  end

  it "should have a cancel! method" do
    @test_run.cancel!
    @test_run.state.should == 'cancelled'
    @test_run.finished_at.should_not be_nil
    @test_group_1.reload
    @test_group_1.state.should == 'cancelled'
    @test_group_1.finished_at.should_not be_nil
    @test_group_2.reload
    @test_group_2.state.should == 'cancelled'
    @test_group_2.finished_at.should_not be_nil
  end
end

describe TestRun, 'update_aggregate_date' do
  before(:each) do
    @test_context = test_contexts(:one)
    @test_run = TestRun.create!(:test_context_id => @test_context.id, :state => 'running')
    @test_group_1 = TestGroup.create!(:test_run_id => @test_run.id, :user_id => 1, :test_group_template_id => 1, :state => 'running')
    @test_group_2 = TestGroup.create!(:test_run_id => @test_run.id, :user_id => 1, :test_group_template_id => 2, :state => 'running')
  end

  it "should set state and finished_at" do
    @test_run.finish!
    @test_run.state.should == 'running'
    
    @test_group_1.state = 'finished_with_failure'
    @test_group_1.finished_at = Time.now
    @test_group_1.save!

    @test_run.finish!
    @test_run.state.should == 'running'
    
    @test_group_2.state = 'finished_with_success'
    @test_group_2.finished_at = Time.now
    @test_group_2.save!
    
    @test_run.finish!
    @test_run.state.should == 'finished_with_failure'
    @test_run.finished_at.to_i.should == @test_group_2.finished_at.to_i  
  end

  it "should update the state of test groups" do
    TestTask.create!(
      :test_group_id => @test_group_1.id,
      :test_task_template_id => 1,
      :state => 'finished_with_success'
    )
    TestTask.create!(
      :test_group_id => @test_group_2.id,
      :test_task_template_id => 1,
      :state => 'finished_with_success'
    )
    @test_run.update_state!
    @test_group_1.reload.state.should == 'finished_with_success'
    @test_group_2.reload.state.should == 'finished_with_success'
    @test_run.reload.state.should == 'finished_with_success'
  end
end

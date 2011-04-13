require 'spec_helper'

describe TestGroup do
  fixtures :test_runs
  before(:each) do
    @test_run = test_runs(:one)
    @user = User.first
    @test_group_template = TestGroupTemplate.create!(:name => 'Doorway')
    @test_group = TestGroup.create!(
      :test_run_id => @test_run.id,
      :user_id => @user.id,
      :test_group_template_id => @test_group_template.id,
      :state => 'running'
    )
  end

  it "should belongs to test_run" do
    @test_group.test_run.should == @test_run
  end

  it "should belongs to test_group_template" do
    @test_group.test_group_template.should == @test_group_template
  end

  it "should belongs to user" do
    @test_group.user.should == @user
  end

  it "should has many test_tasks" do
    TestTask.create!(:test_group_id => @test_group.id, :test_task_template_id => 1, :state => 'running')
    TestTask.create!(:test_group_id => @test_group.id, :test_task_template_id => 2, :state => 'running')
    @test_group.test_tasks.count.should == 2
  end
end

describe TestGroup, 'AASM' do
  fixtures :test_runs
  before(:each) do
    @test_run = test_runs(:one)
    @user = User.first
    @test_group_template = TestGroupTemplate.create!(:name => 'Doorway')
    @test_group = TestGroup.create!(
      :test_run_id => @test_run.id,
      :user_id => @user.id,
      :test_group_template_id => @test_group_template.id,
      :state => 'running'
    )
    @test_task_1 = TestTask.create!(:test_group_id => @test_group.id, :test_task_template_id => 1, :state => 'running')
    @test_task_2 = TestTask.create!(:test_group_id => @test_group.id, :test_task_template_id => 2, :state => 'running')
  end

  it "should have correct state!" do
    @test_group.test_tasks.running?.should == true
    @test_group.test_tasks.done?.should == false

    @test_task_1.state = 'finished_with_failure'
    @test_task_1.save!
    @test_group.test_tasks.finished_with_failure?.should == false

    @test_task_2.state = 'finished_with_success'
    @test_task_2.save!
    @test_group.test_tasks.finished_with_failure?.should == true

    @test_task_1.state = 'finished_with_success'
    @test_task_1.save!
    @test_task_2.state = 'finished_with_success'
    @test_task_2.save!
    @test_group.test_tasks.finished_with_success?.should == true
  end

  it "should have a cancel! method" do
    @test_group.cancel!
    @test_group.state.should == 'cancelled'
    @test_group.finished_at.should_not be_nil
    @test_task_1.reload
    @test_task_1.state.should == 'cancelled'
    @test_task_1.finished_at.should_not be_nil
    @test_task_2.reload
    @test_task_2.state.should == 'cancelled'
    @test_task_2.finished_at.should_not be_nil
  end
end

describe TestGroup, 'update_aggregate_date' do
  fixtures :test_groups, :test_runs
  before(:each) do
    @test_group = test_groups(:one)
    @test_task_1 = TestTask.create!(:test_group_id => @test_group.id, :test_task_template_id => 1, :state => 'running')
    @test_task_2 = TestTask.create!(:test_group_id => @test_group.id, :test_task_template_id => 2, :state => 'running')
  end

  it "should set state and finished_at" do
    @test_group.finish!
    @test_group.state.should == 'running'

    @test_task_1.state = 'finished_with_failure'
    @test_task_1.finished_at = Time.now
    @test_task_1.save!

    @test_group.finish!
    @test_group.state.should == 'running'

    @test_task_2.state = 'finished_with_success'
    @test_task_2.finished_at = Time.now
    @test_task_2.save!

    @test_group.finish!
    @test_group.state.should == 'finished_with_failure'
    @test_group.finished_at.to_i.should == @test_task_2.finished_at.to_i

    test_run = @test_group.test_run.reload
    test_run.state.should == 'finished_with_failure'
    test_run.finished_at.to_i.should == @test_task_2.finished_at.to_i
  end
end

require 'spec_helper'

describe TestTask do
  before(:each) do
    @test_group = test_groups(:one)
    @test_group_template = TestGroupTemplate.create!(:name => 'Doorway')
    @test_task_template = TestTaskTemplate.create!(
      :test_group_template_id => @test_group_template.id,
      :position => 1,
      :text => 'text',
      :expected_outcome => 'expected_outcome'
    )
    @test_task = TestTask.create!(
      :test_group_id => @test_group.id,
      :test_task_template_id => @test_task_template.id,
      :state => 'running'
    )
  end

  it "should belongs to test_group" do
    @test_task.test_group.should == @test_group
  end

  it "should belong to test_task_template" do
    @test_task.test_task_template.should == @test_task_template
  end

  it "should acts_as_list :scope => :test_group" do
    @test_task.position.should == 1
    test_task_2 = TestTask.create!(
      :test_group_id => @test_group.id,
      :test_task_template_id => @test_task_template.id,
      :state => 'running'
    )
    test_task_2.position.should == 2
    @test_group.reload.test_tasks.should == [@test_task, test_task_2]
  end
end

describe TestTask, 'AASM' do
  before(:each) do
    @test_group = test_groups(:one)
    @test_group_template = TestGroupTemplate.create!(:name => 'Doorway')
    @test_task_template = TestTaskTemplate.create!(
      :test_group_template_id => @test_group_template.id,
      :position => 1,
      :text => 'text',
      :expected_outcome => 'expected_outcome'
    )
    @test_task = TestTask.create!(
      :test_group_id => @test_group.id,
      :test_task_template_id => @test_task_template.id,
      :state => 'running'
    )
  end

  it "should have correct state!" do
    @test_task.finish_with_failure!
    @test_task.state.should == 'finished_with_failure'
    @test_task.finished_at.should_not be_nil
  end

   it "should have a cancel! method" do
    @test_task.cancel!
    @test_task.state.should == 'cancelled'
    @test_task.finished_at.should_not be_nil
  end
end

describe TestGroup, 'update_aggregate_date' do
  before(:each) do
    @test_group = test_groups(:one)
    @test_group_template = TestGroupTemplate.create!(:name => 'Doorway')
    @test_task_template = TestTaskTemplate.create!(
      :test_group_template_id => @test_group_template.id,
      :position => 1,
      :text => 'text',
      :expected_outcome => 'expected_outcome'
    )
    @test_task = TestTask.create!(
      :test_group_id => @test_group.id,
      :test_task_template_id => @test_task_template.id,
      :state => 'running'
    )
  end

  it "should set state and finished_at" do
    @test_task.finish_with_failure!

    @test_group.reload
    @test_group.state.should == 'finished_with_failure'
    @test_group.finished_at.to_i.should == @test_task.finished_at.to_i

    test_run = @test_group.test_run.reload
    test_run.state.should == 'finished_with_failure'
    test_run.finished_at.to_i.should == @test_task.finished_at.to_i
  end
end

require 'spec_helper'

describe TestGroupTemplate do
  fixtures :test_contexts, :test_runs, :users
  before(:each) do
    @test_group_template = TestGroupTemplate.create!(:name => 'Doorway')
  end

  it "should has_many test_contextings and test_contexts" do
    test_context_1 = test_contexts(:one)
    test_context_2 = test_contexts(:two)
    TestContexting.create!(
      :test_context_id => test_context_1.id,
      :test_group_template_id => @test_group_template.id
    )
    TestContexting.create!(
      :test_context_id => test_context_2.id,
      :test_group_template_id => @test_group_template.id
    )
    @test_group_template.test_contextings.count.should == 2
    @test_group_template.test_contexts.count.should == 2    
  end
  
  it "should has_many test_task_templates" do
    TestTaskTemplate.create!(
      :test_group_template_id => @test_group_template.id,
      :position => 1,
      :text => 'text',
      :expected_outcome => 'expected_outcome'
    )
    TestTaskTemplate.create!(
      :test_group_template_id => @test_group_template.id,
      :position => 2,
      :text => 'text',
      :expected_outcome => 'expected_outcome'
    )
    @test_group_template.test_task_templates.count.should == 2
  end

  it "should has_many test_groups" do
    test_run_1 = test_runs(:one)
    test_run_2 = test_runs(:two)
    user = users(:tester)
    TestGroup.create!(
      :test_run_id => test_run_1.id,
      :user_id => user.id,
      :test_group_template_id => @test_group_template.id,
      :state => 'running'
    )
    TestGroup.create!(
      :test_run_id => test_run_2.id,
      :user_id => user.id,
      :test_group_template_id => @test_group_template.id,
      :state => 'running'
    )
    @test_group_template.test_groups.count.should == 2
  end
  
end

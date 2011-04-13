require 'spec_helper'

describe TestTaskTemplate do
  fixtures :test_groups, :test_group_templates
  before(:each) do
    @test_group_template = test_group_templates(:one)    
    @test_task_template = TestTaskTemplate.create!(
      :test_group_template_id => @test_group_template.id,
      :position => 1,
      :text => 'text',
      :expected_outcome => 'expected_outcome'
    )
  end

  it "should belongs_to :test_group_template" do
    @test_task_template.test_group_template.should == @test_group_template
  end

  it "should has_many :test_tasks" do
    test_group_1 = test_groups(:one)
    TestTask.create!(
      :test_group_id => test_group_1.id,
      :test_task_template_id => @test_task_template.id,
      :state => 'running'
    )
    test_group_2 = test_groups(:two)
    TestTask.create!(
      :test_group_id => test_group_2.id,
      :test_task_template_id => @test_task_template.id,
      :state => 'running'
    )
    @test_task_template.test_tasks.count.should == 2
  end
  
end

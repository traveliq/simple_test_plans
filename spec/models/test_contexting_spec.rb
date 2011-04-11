require 'spec_helper'

describe TestContexting do
  fixtures :test_contexts, :test_group_templates
  before(:each) do
    @test_context = test_contexts(:one)
    @test_group_template = test_group_templates(:one)
  end

  it "should create a new instance given valid attributes" do
    TestContexting.new(
      :test_context_id => @test_context.id,
      :test_group_template_id => @test_group_template.id
    ).should be_valid
  end
end

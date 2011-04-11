class TestContexting < ActiveRecord::Base

  validates_presence_of :test_context_id, :test_group_template_id
  validates_uniqueness_of :test_context_id, :scope => :test_group_template_id

  belongs_to :test_context
  belongs_to :test_group_template
  
end

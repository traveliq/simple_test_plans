class TestTaskTemplate < ActiveRecord::Base

  validates_presence_of :text, :expected_outcome, :position, :test_group_template_id

  belongs_to :test_group_template
  has_many :test_tasks, :dependent => :destroy

  def to_s
    test_group_template.name + ' ' + position.to_s
  end
  
end

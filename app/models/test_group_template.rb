class TestGroupTemplate < ActiveRecord::Base

  validates_presence_of :name

  has_many :test_contextings, :dependent => :destroy
  has_many :test_contexts, :through => :test_contextings
  has_many :test_task_templates, :dependent => :destroy do
    def not_deleted
      all(:conditions => { :deleted_at => nil})
    end
  end
  has_many :test_groups, :dependent => :destroy
  
end

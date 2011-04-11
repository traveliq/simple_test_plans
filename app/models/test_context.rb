class TestContext < ActiveRecord::Base
  
  validates_presence_of :name

  has_many :test_runs
  has_many :test_contextings
  has_many :test_group_templates, :through => :test_contextings do
    def not_deleted
      all(:conditions => { :deleted_at => nil})
    end
  end

end

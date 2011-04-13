# This is just a stub model - use your own authentication/authorization scheme.
class User < ActiveRecord::Base
  has_many :test_groups
  validates_presence_of :email
  validates_uniqueness_of :email

  def to_s
    "#{self.class.name}##{id}:#{email}"
  end
end

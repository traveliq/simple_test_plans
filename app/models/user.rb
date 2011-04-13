# This is just a stub model - use your own authentication/authorization scheme.
class User < ActiveRecord::Base
  has_many :test_groups
  validates_presence_of :email
end

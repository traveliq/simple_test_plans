class UsersController < ApplicationController

  active_scaffold :users do |config|
    config.create.columns = [:email]
  end
end

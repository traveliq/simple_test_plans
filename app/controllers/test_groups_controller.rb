class TestGroupsController < ApplicationController

  active_scaffold :test_groups do |config|
    config.columns = [:id, :state, :test_group_template, :message, :finished_at, :user, :test_run, :test_tasks]
    config.columns[:test_tasks].label = 'Test Tasks'
    config.columns[:test_run].clear_link
    config.columns[:test_group_template].clear_link
    config.columns[:user].clear_link
    config.show.columns = [:id, :state, :test_group_template, :finished_at, :user, :test_run]
    config.actions.exclude :delete, :create, :update, :show
    config.columns[:test_run].includes = [:test_run => :test_context]
  end  

end

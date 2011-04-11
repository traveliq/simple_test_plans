class TestContextsController < ApplicationController
  
  active_scaffold :test_contexts do |config|
    config.columns = [:id, :name, :test_runs]
    config.columns[:test_runs].label = 'Test Runs'
    config.create.columns = [:name]
    config.show.columns = [:id, :name]
    config.update.columns = [:name]
    config.actions.exclude :delete
    config.nested.add_link('Test Contextings', :test_contextings)
  end

end

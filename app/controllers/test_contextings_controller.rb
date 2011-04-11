class TestContextingsController < ApplicationController

  active_scaffold :test_contextings do |config|
    config.columns = [:test_context, :test_group_template]
    config.columns[:test_group_template].clear_link
    config.columns[:test_context].clear_link
    config.columns[:test_context].form_ui = :select
    config.columns[:test_group_template].form_ui = :select
    config.actions.exclude :show
  end
end

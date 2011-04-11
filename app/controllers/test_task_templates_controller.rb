class TestTaskTemplatesController  < ApplicationController

  active_scaffold :test_task_templates do |config|
    config.columns = [:id, :text, :expected_outcome, :position, :test_group_template, :deleted_at]
    config.create.columns = [:text, :expected_outcome, :position, :test_group_template]
    config.update.columns = [:text, :expected_outcome, :position, :test_group_template]
    config.columns[:test_group_template].clear_link
    config.columns[:test_group_template].form_ui = :select
    config.actions.exclude :show, :delete
    config.nested.add_link('Test Tasks', :test_tasks)
    #config.delete.link.confirm = "All its test tasks will be deleted! Are you sure? After it, check the continuity of remaining test task templates' position."
    config.action_links.add 'soft_delete', :label => 'Change deleted_at',:inline=> false, :type => :member
  end

  def soft_delete
    tgt = TestGroupTemplate.find(params[:id])
    tgt.deleted_at ? tgt.update_attribute(:deleted_at, nil) : tgt.update_attribute(:deleted_at, Time.now.utc)
    redirect_to(:back)
  end
end

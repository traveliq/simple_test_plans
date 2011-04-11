class TestGroupTemplatesController < ApplicationController

  active_scaffold :test_group_templates do |config|
    config.columns = [:id, :name, :deleted_at]
    config.create.columns = [:name, :test_group_template_contexts]
    config.update.columns = [:name]
    config.actions.exclude :show, :delete
    config.nested.add_link('Test Contextings', :test_contextings)
    config.nested.add_link('Test Groups', :test_groups)
    config.nested.add_link('Test Task Templates', :test_task_templates)
    #config.delete.link.confirm = 'All its test contextings, test groups, test task templates and test tasks will be deleted! Are you sure?'
    config.action_links.add 'soft_delete', :label => 'Change deleted_at',:inline=> false, :type => :member
  end

  def soft_delete
    tgt = TestGroupTemplate.find(params[:id])
    tgt.deleted_at ? tgt.update_attribute(:deleted_at, nil) : tgt.update_attribute(:deleted_at, Time.now.utc)
    redirect_to(:back)
  end

  protected

  def do_create
    begin
      active_scaffold_config.model.transaction do
        @record = update_record_from_params(active_scaffold_config.model.new, active_scaffold_config.create.columns, params[:record])
        apply_constraints_to_record(@record, :allow_autosave => true)
        self.successful = [@record.valid?, @record.associated_valid?].all? {|v| v == true}
        contexts = params.delete('contexts')
        if contexts.blank? or contexts.keys.blank?
          @record.errors.add('Test Contexts', 'Dieses Feld muss ausgefüllt werden.')
          self.successful = false
        end
        if successful?
          @record.save! and @record.save_associated!
          contexts.keys.each do |context|
            @record.test_contexts << TestContext.find_by_id(context)
          end
        end
      end
    rescue ActiveRecord::RecordInvalid
    end
  end
  
end

class TestTasksController < ApplicationController

  before_filter :show_ticket_number
  before_filter :create_ticket

  layout 'admin/active_scaffold'

  active_scaffold :test_tasks do |config|
    config.columns = [:id, :state, :test_group, :task_template_text, :task_template_outcome, :position, :finished_at, :ticket_number, :comment]
    config.columns[:task_template_text].label = 'Text'
    config.columns[:task_template_outcome].label = 'Outcome'
    config.update.columns = [:task_template_text, :task_template_outcome, :ticket_number, :comment, :test_task_state]
    config.columns[:test_group].clear_link
    config.actions.exclude :delete, :create
    config.update.link.popup = true
    config.columns[:test_group].includes = [:test_task_template, {:test_group => [:test_group_template, {:test_run => :test_context}]}]
  end

  def update
    do_update
    if successful?
      test_group = @record.test_group
      next_task = test_group.next_unfinished_task
      if next_task.nil? and next_group = test_group.test_run.next_unfinished_group(test_group.user.id)
        next_task = next_group.next_unfinished_task
      end
      if next_task
        redirect_to :action => 'edit', :id => next_task.id
      else
        test_run = test_group.test_run
        params.delete('id')
        redirect_to "/admin/test_contexts/#{test_run.test_context.id}/test_runs/#{test_run.id}"
      end
    else
      render(:action => 'update', :layout => true)
    end    
  end

  protected
 
  def do_update
    @record = TestTask.find(params[:id])
    active_scaffold_config.model.transaction do
      @record = update_record_from_params(@record, active_scaffold_config.update.columns, params[:record])
      commit = params.delete('commit')
      if @record.state == 'cancelled'
        @record.errors.add('state', "This task has benn cancelled, please click 'Cancel'")
        self.successful = false
      elsif @record.running? and commit == 'Update'
        @record.errors.add('state', "State can't be blank")
        self.successful = false
      else
        self.successful = true
      end
      if commit == 'Fail' and @record.comment.blank?
        @record.errors.add('comment', "Comment can't be blank, if result is fail")
        self.successful = false
      end
      if successful?
        if commit  == 'Update'
          @record.send("#{@record.state.gsub('finished', 'finish')}!") and @record.save_associated!
        else
          state = case commit
          when 'Pass' then 'success'
          when 'Fail' then 'failure'
          when 'N/A' then 'na'
          end
          @record.send("finish_with_#{state}!") and @record.save_associated!
        end
      end
    end
  end

  def show_ticket_number
    if test_task_id = params[:id] and
        test_task = TestTask.find_by_id(test_task_id) and
        !(test_task.test_group.test_run.test_context.name =~ /deploy/i) and
        test_task.state == 'running'
      active_scaffold_config.update.columns.exclude :ticket_number
    end
  end

end

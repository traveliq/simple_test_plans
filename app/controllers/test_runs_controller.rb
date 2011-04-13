class TestRunsController < ApplicationController

  before_filter :update_table_config

  active_scaffold :test_runs do |config| 
    config.columns = [:id, :test_context, :created_at, :updated_at, :finished_at, :duration, :message, :state, :test_groups]
    config.columns[:test_groups].label = 'Test Groups'
    config.columns[:test_context].clear_link
    config.create.columns = [:test_run_users, :message, :test_run_group_templates]
    config.create.link = false
    config.show.columns = [:id, :test_context, :created_at, :updated_at, :finished_at, :duration, :message, :state]
    config.update.columns = [:message]
    config.actions.exclude :delete
    config.action_links.add 'Cancel', :action=>'cancel', :inline=> true, :type => :member, :confirm => 'Are you sure?'    
    config.action_links.add "Daily Test feed", :action=> 'dailies', :popup =>true
    config.list.sorting = { :created_at => :desc }
    config.show.link.popup = true
  end

  def cancel
    test_run = TestRun.find(params['id'])
    if test_run.state == 'running'
      test_run.cancel!
      render :text => 'Cancelled Successfully!'
    else
      render :text => 'Only a running test run can be cancelled!'
    end
  end

  # The RSS feed
  def dailies
    n = if params[:n] then params[:n].to_i else 20 end
    @test_runs = if params[:date].blank?
      TestRun.find(:all, :limit => n, :order => 'id DESC')
    else
      TestRun.find(:all, :conditions => ["date(created_at) = ?", params[:date]], :limit => n, :order => 'id DESC')
    end
    
    render :layout => false
  end

  def new
    if params['test_context_id'].blank?
      flash[:info] = 'Please click a new link.'
      redirect_to :action => :index
    else
      super
    end
  end

  def create
    do_create
    if successful?
      @record.reload
      redirect_to(:action => :index)
    else
      render(:action => 'create_form', :layout => true)
    end
  end

  protected
  
  def do_create
    begin
      active_scaffold_config.model.transaction do
        @record = update_record_from_params(active_scaffold_config.model.new, active_scaffold_config.create.columns, params[:record])
        test_context_id = params['test_context_id']
        @record.test_context_id = test_context_id
        test_context = TestContext.find(test_context_id)
        apply_constraints_to_record(@record, :allow_autosave => true)
        self.successful = [@record.valid?, @record.associated_valid?].all? {|v| v == true}
        test_group_templates = params.delete('tgts')
        test_group_templates ||= {}
        testers = params.delete('testers')
        testers ||= {}
        if testers.blank? or testers.keys.blank?
          @record.errors.add('Testers', 'Dieses Feld muss ausgefüllt werden.')
          self.successful = false
        end
        if test_group_templates.blank? or test_group_templates.keys.blank?
          @record.errors.add('Test Group Templates', 'Dieses Feld muss ausgefüllt werden.')
          self.successful = false
        end
        if successful?
          @record.save! and @record.save_associated!
          @record.init(testers.keys, test_group_templates.keys, "https://#{request.host_with_port}")
        end
      end
    rescue ActiveRecord::RecordInvalid
    end
  end

  def update_table_config
    tcs = TestContext.find(:all, :order => 'name desc')
    tcs.each do |tc|
      active_scaffold_config.action_links.add "New #{tc.name} Test", :action=> 'new', :parameters=> {:test_context_id => tc.id}, :popup =>true
    end
  end
   
end

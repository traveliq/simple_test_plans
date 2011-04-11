class TestRun < ActiveRecord::Base
  include AASM

  validates_presence_of :test_context_id, :state

  belongs_to :test_context

  has_many :test_groups, :dependent => :destroy do
    
    def done?; running.count == 0 or cancelled.count > 0 end
    
    def running?; running.count > 0; end

    def cancelled?; cancelled.count > 0 end

    def finished_with_failure?; running.count == 0 and cancelled.count == 0 and finished_with_failure.count > 0 end

    def finished_with_na?; running.count == 0 and cancelled.count == 0 and finished_with_failure.count == 0 and finished_with_na.count > 0 end

    def finished_with_success?; finished_with_success.count > 0 and finished_with_success.count == count end
   
    def finished_at
      return nil unless count(:conditions => { :finished_at => nil}).zero?
      first(:order => 'finished_at DESC').finished_at
    end

    def finish!; each(&:finish!); end
  end

  has_many :test_tasks, :through => :test_groups

  aasm_column :state

  aasm_state  :running

  aasm_state  :finished_with_success

  aasm_state  :finished_with_failure

  aasm_state  :finished_with_na

  aasm_state  :cancelled


  aasm_event :finish_with_success do
    transitions :from => [:running, :finished_with_success, :finished_with_failure, :finished_with_na],
      :to => :finished_with_success,
      :on_transition => :set_finished_at,
      :guard => lambda { |tr| tr.test_groups.finished_with_success? }
  end

  aasm_event :finish_with_failure do
    transitions :from => [:running, :finished_with_success, :finished_with_failure, :finished_with_na],
      :to => :finished_with_failure,
      :on_transition => :set_finished_at,
      :guard => lambda { |tr| tr.test_groups.finished_with_failure? }
  end

  aasm_event :finish_with_na do
    transitions :from => [:running, :finished_with_success, :finished_with_failure, :finished_with_na],
      :to => :finished_with_na,
      :on_transition => :set_finished_at,
      :guard => lambda { |tr| tr.test_groups.finished_with_na? }
  end

  aasm_event :cancel, :success => :cancel_test_groups do
    transitions :from => :running,
      :to => :cancelled,
      :on_transition => :set_cancel_finished_at
  end

  def update_state!
    test_groups.finish!
  end

  def finish!
    unless finish_with_failure!
      unless finish_with_na!
        finish_with_success!
      end
    end
  end

  def set_finished_at
    self.finished_at = test_groups.finished_at
  end

  def set_cancel_finished_at
    self.finished_at = Time.now
  end


  def cancel_test_groups
    test_groups.each do |tg|
      tg.cancel! if tg.state == 'running'
    end
  end

  def init_test_group_templates(tgts = nil)
    templates = []
    if test_context.name =~ /deploy/i
      test_context.test_group_templates.not_deleted.each do |tgt|
        next unless tgts.include?(tgt.id.to_s)
        templates << [tgt, nil]
      end
    elsif test_context.name =~ /hotel/i or test_context.name =~ /flight/i
      class_name = test_context.name =~ /hotel/i ? HotelsParser : FlightsParser
      parsers = class_name.enabled.all
      test_context.test_group_templates.find(:all, :conditions => "deleted_at is null and name like '%General%'").each do |tgt|
        templates << [tgt, nil]
      end
      test_group_templates = test_context.test_group_templates.find(:all, :conditions => "deleted_at is null and name not like '%General%'")
      parsers.each do |p|
        next unless p.handles?(self.search)
        test_group_templates.each do |tgt|
        templates << [tgt, p.name]
        end
      end
    end
    templates
  end

  def init(testers, tgts, host)
    testers = [current_user.id] if testers.size == 0
    init_search
    testers_array = []
    init_test_group_templates(tgts).each do |tgt, message|
      testers_array = testers.clone if testers_array.size == 0
      tester = testers_array.rand
      testers_array.delete(tester)
      test_group = TestGroup.create!(
        :test_run_id => id,
        :user_id => tester,
        :test_group_template_id => tgt.id,
        :state => 'running',
        :message => message
      )
      test_task_templates = tgt.test_task_templates.not_deleted
      1.upto(test_task_templates.size) do |position|
        ttt_selected = test_task_templates.select do |ttt|
          ttt.position == position
        end.rand
        break unless ttt_selected
        TestTask.create!(
          :test_group_id => test_group.id,
          :test_task_template_id => ttt_selected.id,
          :state => 'running'
        )
      end      
    end
    if test_context.name =~ /deploy/i
      reload.test_groups.each do |tg|
        tester = tg.user
        if testers.include?(tester.id.to_s)
          url = "#{host}/admin/test_contexts/#{test_context.id}/test_runs/#{id}/test_groups/#{tg.id}/test_tasks/#{tg.test_tasks.first.id}/edit"
          UserMailer.deliver_test_task(tester, url, "#{tg.to_s}")
          testers.delete(tester.id.to_s)
        end
      end
    end
  end

  def to_s
    "#{created_at.localtime.strftime("%d.%m.%y")} #{test_context.name} #{message} #{search}"
  end

  def next_unfinished_group(user_id)
    test_groups.find_by_state_and_user_id('running', user_id)
  end

end

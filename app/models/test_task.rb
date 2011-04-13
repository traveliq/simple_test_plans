class TestTask < ActiveRecord::Base
  include AASM


  validates_presence_of :state, :test_group_id, :test_task_template_id

  belongs_to :test_group
  belongs_to :test_task_template

  acts_as_list :scope => :test_group

  aasm_column :state

  aasm_state  :running

  aasm_state  :finished_with_success

  aasm_state  :finished_with_failure

  aasm_state  :finished_with_na

  aasm_state  :cancelled

  named_scope :running,
    :conditions => { :state => 'running' }

  named_scope :finished_with_success,
    :conditions => { :state => 'finished_with_success' }

  named_scope :finished_with_failure,
    :conditions => { :state => 'finished_with_failure' }

  named_scope :finished_with_na,
    :conditions => { :state => 'finished_with_na' }

  named_scope :cancelled,
    :conditions => { :state => 'cancelled' }

  aasm_event :finish_with_success, :success => :finish_test_group do
    transitions :from => [:running, :finished_with_success, :finished_with_failure, :finished_with_na],
      :to => :finished_with_success,
      :on_transition => :set_finished_at
  end

  aasm_event :finish_with_failure, :success => :finish_test_group do
    transitions :from => [:running, :finished_with_success, :finished_with_failure, :finished_with_na],
      :to => :finished_with_failure,
      :on_transition => :set_finished_at
  end

  aasm_event :finish_with_na, :success => :finish_test_group do
    transitions :from => [:running, :finished_with_success, :finished_with_failure, :finished_with_na],
      :to => :finished_with_na,
      :on_transition => :set_finished_at
  end

  aasm_event :cancel do
    transitions :from => :running,
      :to => :cancelled,
      :on_transition => :set_cancel_finished_at
  end

  def set_finished_at
    self.finished_at = Time.now
  end

  def set_cancel_finished_at
    self.finished_at = Time.now
  end

  def finish_test_group
    test_group.finish!
  end

  def tester_finished_tasks
    test_group.test_run.test_tasks.count(:conditions => "test_groups.user_id = #{test_group.user.id} and test_tasks.state != 'running'")
  end

  def tester_total_tasks
    test_group.test_run.test_tasks.count(:conditions => "test_groups.user_id = #{test_group.user.id}")
  end

  def to_s
    "#{test_group} (Test #{position}/#{test_group.test_tasks.count}), (Total #{tester_finished_tasks + 1}/#{tester_total_tasks})"
  end

  def ticket_number
    ticket_number = self[:ticket_number]
    if ticket_number.blank?
      '-'
    else
      link_to "##{ticket_number}", "http://your-issue-tracker.com/show/#{ticket_number}"
    end
  end

  def task_template_text
    test_task_template.text
  end

  def task_template_outcome
    test_task_template.expected_outcome
  end
  
end

class TestGroup < ActiveRecord::Base
  include AASM
  validates_presence_of :user_id, :test_run_id, :test_group_template_id, :state

  belongs_to :user
  belongs_to :test_run
  belongs_to :test_group_template
  has_many :test_tasks, :order => "position", :dependent => :destroy do

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
  end
  
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


  aasm_event :finish_with_success, :success => :finish_test_run do
    transitions :from => [:running, :finished_with_success, :finished_with_failure, :finished_with_na],
      :to => :finished_with_success,
      :on_transition => :set_finished_at,
      :guard => lambda { |tg| tg.test_tasks.finished_with_success? }
  end

  aasm_event :finish_with_failure, :success => :finish_test_run do
    transitions :from => [:running, :finished_with_success, :finished_with_failure, :finished_with_na],
      :to => :finished_with_failure,
      :on_transition => :set_finished_at,
      :guard => lambda { |tg| tg.test_tasks.finished_with_failure? }
  end

  aasm_event :finish_with_na, :success => :finish_test_run do
    transitions :from => [:running, :finished_with_success, :finished_with_failure, :finished_with_na],
      :to => :finished_with_na,
      :on_transition => :set_finished_at,
      :guard => lambda { |tg| tg.test_tasks.finished_with_na? }
  end

  aasm_event :cancel, :success => :cancel_test_tasks  do
    transitions :from => :running,
      :to => :cancelled,
      :on_transition => :set_cancel_finished_at
  end

  def finish!
    unless finish_with_failure!
      unless finish_with_na!
        finish_with_success!
      end
    end
  end
  
  def set_finished_at
    self.finished_at = test_tasks.finished_at
  end
  
  def set_cancel_finished_at
    self.finished_at = Time.now
  end

  def finish_test_run
    test_run.finish!
  end

  def cancel_test_tasks
    test_tasks.each do |tt|
      tt.cancel! if tt.state == 'running'
    end
  end

  def to_s
    "#{test_run} #{test_group_template.name} #{message}"
  end

  def next_unfinished_task
    test_tasks.find_by_state('running')
  end
  
end

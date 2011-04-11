module TestTasksHelper
  def test_task_task_template_text_column(record)
    record.test_task_template.text
  end
  
  def test_task_task_template_outcome_column(record)
    record.test_task_template.expected_outcome
  end

  def test_task_ticket_number_column(record)
    if record.ticket_number.blank?
      '-'
    else
      link_to "##{record.ticket_number}", "http://your-issue-tracker.com/show/#{record.ticket_number}"
    end
  end

  def test_task_state_column(record)
    test_state(record.state)
  end

end

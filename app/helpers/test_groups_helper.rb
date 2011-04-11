module TestGroupsHelper
  def test_group_test_tasks_column(record)
    link_to 'Test Tasks', test_context_test_run_test_group_test_tasks_url(record.test_run.test_context, record.test_run, record), :popup => true
  end

  def test_group_state_column(record)
    test_state(record.state)
  end
end

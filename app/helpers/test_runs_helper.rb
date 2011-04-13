module TestRunsHelper

  def test_run_test_groups_column(record)
    link_to 'Test Groups', test_context_test_run_test_groups_url(record.test_context, record), :popup => true
  end

  def test_run_state_column(record)
    test_state(record.state)
  end
end

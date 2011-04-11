module TestContextsHelper
  def test_context_test_runs_column(record)
    link_to 'Test Runs', test_context_test_runs_url(record), :popup => true
  end
end

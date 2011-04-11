module TestRunsHelper

  def test_run_duration_column(record)
    if record.finished_at
      duration = record.finished_at - record.created_at
      if duration < 60
        "#{duration} sec"
      elsif duration < 3600
        "#{(duration / 60).to_i} min #{(duration % 60).to_i} sec"
      else
        hour = (duration / 3600).to_i
        duration = (duration % 3600).to_i
        "#{hour} hours #{(duration / 60).to_i} mins #{(duration % 60).to_i} secs"
      end
    else
      nil
    end
  end

  def test_run_test_groups_column(record)
    link_to 'Test Groups', test_context_test_run_test_groups_url(record.test_context, record), :popup => true
  end

  def test_run_state_column(record)
    test_state(record.state)
  end
end

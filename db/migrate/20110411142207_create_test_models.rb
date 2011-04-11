class CreateTestModels < ActiveRecord::Migration
  def self.up
    
    create_table "test_contextings", :force => true do |t|
      t.integer  "test_context_id",        :null => false
      t.integer  "test_group_template_id", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    add_index "test_contextings", ["test_context_id"], :name => "index_test_contextings_on_test_context_id"
    add_index "test_contextings", ["test_group_template_id"], :name => "index_test_contextings_on_test_group_template_id"
      
    create_table "test_contexts", :force => true do |t|
      t.string   "name",       :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    create_table "test_group_templates", :force => true do |t|
      t.string   "name",       :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
    end
    
    create_table "test_groups", :force => true do |t|
      t.integer  "user_id",                :null => false
      t.string   "state",                  :null => false
      t.integer  "test_run_id",            :null => false
      t.integer  "test_group_template_id", :null => false
      t.datetime "finished_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "message"
    end
    
    add_index "test_groups", ["test_group_template_id"], :name => "index_test_groups_on_test_group_template_id"
    add_index "test_groups", ["test_run_id"], :name => "index_test_groups_on_test_run_id"
    
    create_table "test_runs", :force => true do |t|
      t.string   "message"
      t.string   "state",           :null => false
      t.integer  "test_context_id", :null => false
      t.datetime "finished_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "search_id"
      t.string   "search_type"
    end
    
    add_index "test_runs", ["test_context_id"], :name => "index_test_runs_on_test_context_id"
    
    create_table "test_task_templates", :force => true do |t|
      t.text     "text",                   :null => false
      t.text     "expected_outcome",       :null => false
      t.integer  "position",               :null => false
      t.integer  "test_group_template_id", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
    end
    
    add_index "test_task_templates", ["test_group_template_id"], :name => "index_test_task_templates_on_test_group_template_id"
    
    create_table "test_tasks", :force => true do |t|
      t.string   "state",                 :null => false
      t.string   "ticket_number"
      t.string   "comment"
      t.integer  "test_group_id",         :null => false
      t.integer  "test_task_template_id", :null => false
      t.datetime "finished_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "position"
    end
    
    add_index "test_tasks", ["test_group_id"], :name => "index_test_tasks_on_test_group_id"
    add_index "test_tasks", ["test_task_template_id"], :name => "index_test_tasks_on_test_task_template_id"
  end

  def self.down
    drop_table "test_contextings"
    drop_table "test_contexts"
    drop_table "test_group_templates"
    drop_table "test_groups"
    drop_table "test_runs"
    drop_table "test_task_templates"
    drop_table "test_tasks"
  end
end

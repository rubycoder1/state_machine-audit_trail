require 'active_record'

### Setup test database

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

ActiveRecord::Base.connection.create_table(:active_record_test_models) do |t|
  t.string :state
  t.string :type
  t.timestamps
end

ActiveRecord::Base.connection.create_table(:active_record_test_model_with_multiple_state_machines) do |t|
  t.string :first
  t.string :second
  t.timestamps
end

# We probably want to provide a generator for this model and the accompanying migration.
class ActiveRecordTestModelStateTransition < ActiveRecord::Base
  belongs_to :test_model
end

class ActiveRecordTestModelWithMultipleStateMachinesFirstTransition < ActiveRecord::Base
  belongs_to :test_model
end

class ActiveRecordTestModelWithMultipleStateMachinesSecondTransition < ActiveRecord::Base
  belongs_to :test_model
end

class ActiveRecordTestModel < ActiveRecord::Base

  state_machine :state, :initial => :waiting do # log initial state?
    store_audit_trail 

    event :start do
      transition [:waiting, :stopped] => :started
    end
    
    event :stop do
      transition :started => :stopped
    end
  end
end

class ActiveRecordTestModelDescendant < ActiveRecordTestModel
end

class ActiveRecordTestModelWithMultipleStateMachines < ActiveRecord::Base

  state_machine :first, :initial => :beginning do
    store_audit_trail 

    event :begin_first do
      transition :beginning => :end
    end
  end
  
  state_machine :second do
    store_audit_trail 

    event :begin_second do
      transition nil => :beginning_second
    end
  end
end

def create_transition_table(owner_class, state)
  class_name = "#{owner_class.name}#{state.to_s.camelize}Transition"
  
  ActiveRecord::Base.connection.create_table(class_name.tableize) do |t|
    t.integer owner_class.name.foreign_key
    t.string :event
    t.string :from
    t.string :to
    t.datetime :created_at
  end
end

create_transition_table(ActiveRecordTestModel, :state)  
create_transition_table(ActiveRecordTestModelWithMultipleStateMachines, :first)  
create_transition_table(ActiveRecordTestModelWithMultipleStateMachines, :second)  

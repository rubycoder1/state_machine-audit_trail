class StateMachine::AuditTrail::Backend::ActiveRecord < StateMachine::AuditTrail::Backend

  def log(object, event, from, to, timestamp = Time.now, opts = {})
    # Let ActiveRecord manage the timestamp for us so it does the 
    # right thing with regards to timezones.
    attrs = {foreign_key_field(object) => object.id, :event => event, :from => from, :to => to}.merge(opts)
    transition_class.create(attrs)
  end

  def foreign_key_field(object)
    object.class.base_class.name.foreign_key.to_sym
  end
end

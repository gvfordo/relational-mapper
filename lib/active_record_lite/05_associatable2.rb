require_relative '04_associatable'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    # ...
    define_method(name) do 
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]   
      source_table = source_options.class_name.constantize.table_name
      join_table = through_options.class_name.constantize.table_name
      join_table_key = self.send(through_name).id
      p source_options
      query = <<-SQL
      SELECT #{source_table}.*
      FROM #{source_table} 
      JOIN #{join_table} ON #{source_table}.#{source_options.primary_key} = #{join_table}.#{source_options.foreign_key}
      WHERE #{source_table}.id = #{join_table_key}
      SQL
      source_options.model_class.parse_all(DBConnection.execute(query)).first
    end
  end
  
  
  
end

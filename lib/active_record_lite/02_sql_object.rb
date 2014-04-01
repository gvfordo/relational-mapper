require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'
class MassObject
  def self.parse_all(results)
    # ...
    new_objects = []
    results.each do |result|
      c = self.new(result)
      new_objects << c #self.new(result)
    end
    new_objects
  end
end


class SQLObject < MassObject
  def self.columns
    @columns ||= (
    query = <<-SQL
    SELECT *
    FROM #{self.table_name}
    SQL
 
    column_names = DBConnection.execute2(query)[0]
  
    column_names.each do |column|
      
      define_method(column.to_s) do
        self.attributes[column.to_s]
      end
    
      define_method("#{column.to_s}=") do |value|
        self.attributes[column.to_s] = value
      end
    end
    column_names.map(&:to_sym))
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    @table_name ||= self.name.underscore.downcase.pluralize
  end

#[:open, :reset, :instance, :execute, :execute2, :last_insert_row_id]

  def self.all
    # ...
    query = <<-SQL
    SELECT *
    FROM #{self.table_name}
    SQL
    parse_all(DBConnection.execute(query))
  end

  def self.find(id)
    # ...
    query = <<-SQL
    SELECT *
    FROM #{self.table_name}
    WHERE
    id = ?
    SQL
    records = DBConnection.execute(query, id)
    parse_all(records)[0]
  end

  def attributes
    @attributes ||= Hash.new
    # ...
  end

  def insert
    # ...
    columns = @attributes.keys.map(&:to_s).join(", ")
    values = @attributes.values.map do |value|
      if value.is_a?(String)
        "'#{value}'"
      else
        value
      end
    end.join(", ")
    query = <<-SQL
    INSERT INTO #{self.class.table_name} (#{columns})
    VALUES (#{values})
    SQL
    DBConnection.execute(query)
    self.send("id=", DBConnection.last_insert_row_id)
    
  end
  
  def initialize(params = Hash.new)
    self.class.columns
    params.each do |attr_name, value|
     unless self.class.columns.include?(attr_name.to_sym)
       raise "unknown attribute '#{attr_name}'"
     end
     attr_set = "#{attr_name}="
     self.send(attr_set, value)
          
     # set_variable = "@#{attr_name}="
    #  self.send(set_variable, value)
    end
    
  end

  def save
    # ...
    if self.attributes["id"].nil?
      self.insert
    else
      self.update
    end
  end

  def update
    # ...
    set_line = []
    @attributes.keys.each do |attr_name|
      next if attr_name == "id"
    set_line << "#{attr_name} = :#{attr_name} "
    end
    query = <<-SQL
    UPDATE #{self.class.table_name}
    SET  #{set_line.join(", ")}
    WHERE
    id = :id
    
    SQL
    DBConnection.execute(query, @attributes)
    
  end

  def attribute_values
    # ...
    values = []
    @attributes
    @attributes.each do |name, value|
      values << value
    end
    values
  end
end

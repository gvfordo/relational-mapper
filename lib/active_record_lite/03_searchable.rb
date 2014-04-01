require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    # ...
    where_line = []
    params.each do |column, value|
      if value.is_a?(String)
        where_line << "#{column} = '#{value}' "
      else
        where_line << "#{column} = #{value} "
      end
    end
    query = <<-SQL
    SELECT *
    FROM #{self.table_name}
    WHERE #{where_line.join(" AND ")}
    SQL
    parse_all(DBConnection.execute(query))

  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end

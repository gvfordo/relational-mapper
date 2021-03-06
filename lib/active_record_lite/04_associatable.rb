require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    # ...
    @class_name.camelcase.constantize
  end

  def table_name
    # ...
    model_class::table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @class_name = options[:class_name] || "#{name}".singularize.camelcase
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
    @foreign_key = options[:foreign_key] || ((self_class_name.to_s)+"_id").downcase.to_sym
    @class_name = options[:class_name] || "#{name}".singularize.camelcase
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    # ...
    define_method(name) do
      foreign_key_id = self.send(options.foreign_key)
      options.model_class.where(:id => foreign_key_id).first
    end
    assoc_options[name] = options
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    define_method(name) do
      id = self.send(options.primary_key)
      p options
      
      p options.foreign_key
      options.model_class.where(options.foreign_key => id)
    end
    assoc_options[name] = options
  end

  def assoc_options
    @assoc_options ||= Hash.new
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
    
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end

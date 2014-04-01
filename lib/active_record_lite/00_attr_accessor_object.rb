class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    names.each do |attr|
      define_method(attr.to_s) do
        instance_variable_get(("@" + attr.to_s).to_sym) 
      end
      
      define_method("#{attr.to_s}=") do |value|
        p "@#{attr.to_s}".to_sym
        instance_variable_set("@#{attr.to_s}".to_sym, value)
      end
    end
  end
end

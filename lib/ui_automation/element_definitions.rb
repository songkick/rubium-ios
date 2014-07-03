require 'active_support/core_ext/string/inflections'

module UIAutomation
  module ElementDefinitions
    # Defines a method on an element object that returns another element object.
    #
    # By default, the Javascript method name is underscored (e.g. textField => text_field)
    # and the element returned is generic (UIAutomation::Element).
    #
    # Options:
    # => :type -> (Class) The defined method returns an instance of this class instead.
    # => :as   -> (Symbol) An alternative name to use for the Ruby method name.
    #
    def has_element(js_method_name, opts={})
      define_element_using(:element_proxy_for, js_method_name, opts)
    end
    
    # Defines a method that returns an element array (UIAutomation::ElementArray).
    #
    # By default, the Javascript method name is underscored (e.g. textFields => text_fields)
    # and the element array returns generic elements (UIAutomation::Element).
    #
    # Options:
    # => :type -> (Class) The ElementArray will return elements of this type.
    # => :as   -> (Symbol) An alternative name to use for the Ruby method name.
    #
    def has_element_array(js_method_name, opts={})
      define_element_using(:element_array_proxy_for, js_method_name, opts)
    end
    
    private
    
    def define_element_using(proxy_method, js_method_name, opts)
      method_name = opts[:as] || js_method_name.to_s.underscore

      define_method(method_name) do
        if opts[:type]
          send(proxy_method, js_method_name, opts[:type])
        else
          send(proxy_method, js_method_name)
        end
      end
    end
  end
end

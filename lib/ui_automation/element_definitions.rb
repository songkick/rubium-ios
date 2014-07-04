require 'active_support/core_ext/string/inflections'

module UIAutomation
  module ElementDefinitions
    # Defines a method on an returns an element proxy.
    #
    # By default, the Javascript method name is underscored (e.g. textField => text_field)
    # and the element returned is generic (UIAutomation::Element).
    #
    # @example Define a method 'text_field' that returns a proxy to <self>.textField()
    #   has_element :textField
    #
    # @param [Hash] opts options for defining the method
    # @option opts [Symbol] :as     Use a custom Ruby method name
    # @option opts [Class]  :type   Return a specific UIAutomation::Element sub-class
    # @api private
    def has_element(js_method_name, opts={})
      define_element_using(:element_proxy_for, js_method_name, opts)
    end
    
    # Defines a method that returns an element array proxy.
    #
    # By default, the Javascript method name is underscored (e.g. textFields => text_fields)
    # and the element array contains generic elements (UIAutomation::Element).
    #
    # @example Define a method 'text_fields' that returns a proxy to <self>.textFields() 
    #   has_element :textFields
    #
    # @param [Hash] opts options for defining the method
    # @option opts [Symbol] :as     Use a custom Ruby method name
    # @option opts [Class]  :type   Return elements with this specific UIAutomation::Element sub-class
    # @api private
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

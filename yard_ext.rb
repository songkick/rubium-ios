require 'active_support/core_ext/string/inflections'

class ProxiedElementHandler < YARD::Handlers::Ruby::Base
  handles method_call(:has_element)
  handles method_call(:has_element_array)
  namespace_only
  
  def process
    js_method_name = statement.parameters[0].jump(:tstring_content, :ident).source
    ruby_method_name = js_method_name.to_s.underscore

    object = YARD::CodeObjects::MethodObject.new(namespace, ruby_method_name)
    object.dynamic = true
    object.explicit = false
    register(object)
    
    custom_type = false
    
    if (options_parameter_list = statement.parameters[1])
      # check to see if there is a type
      options_parameter_list.children.each do |assoc_node|
        key_node = assoc_node.children[0]
        if key_node.source =~ /^type/
          type_value_node = assoc_node.children[1]
          set_return_type(object, type_value_node, statement.docstring)
          custom_type = true
        end
      end
    end
    
    set_return_type(object, 'UIAutomation::Element', statement.docstring) unless custom_type
  end
  
  private
  
  def element_array?
    statement.children[0].jump(:tstring_content, :ident).source == "has_element_array"
  end
  
  def set_return_type(method_object, return_type, docstring)
    if return_type.is_a?(YARD::Parser::Ruby::ReferenceNode)
      return_type = return_type.source
    end
    
    return_type = "UIAutomation:ElementArray<#{return_type}>" if element_array?
      
    method_object.add_tag(YARD::Tags::Tag.new(:return, docstring, [return_type]))
  end
end

module UIAutomation
  # Represents objects of type UIAElementArray in the Javascript API.
  #
  # An ElementArray represents a collection of elements of a specific type within the view hierarchy.
  #
  # This class implements #each and includes the Enumerable mixin, enabling you to use it like any other
  # native Ruby collection class.
  #
  # All methods in thie class that return a UIAutomation::Element may return a specific sub-class of 
  # UIAutomation::Element, as determined by the #element_klass attribute.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIAElementArrayClassReference/
  class ElementArray < RemoteProxy
    include Enumerable

    # The proxy for the parent element
    # @note This returns the existing proxy that created this one; it does not use the UIAElement.parent() method
    # @return [UIAutomation::Element]
    attr_reader :parent

    # The window that contains this element
    # @return [UIAutomation::Window]
    attr_reader :window
    
    # The element proxy class used for each element in the array.
    # @api private
    attr_reader :element_klass

    # @api private
    def initialize(executor, remote_object, element_klass = UIAutomation::Element, parent_element = nil, window = nil)
      super executor, remote_object
      @element_klass = element_klass
      @parent = parent_element
      @window = window
    end

    def inspect
      "<RemoteProxy(#{self.class.name}) type:#{element_proxy_for}: #{to_javascript}>"
    end
    
    ### @!group Accessing Elements    

    # Returns a proxy to the element at the given index.
    # 
    # @param [Integer] index
    # @return [UIAutomation::Element] the element proxy
    #
    def at_index(index)
      build_proxy element_klass, remote_object.object_for_subscript(index), [parent, window]
    end

    # Returns a new ElementArray containing all elements with the given name.
    # 
    # @param [String] name
    # @return [UIAutomation::ElementArray] a sub-set of the current element array
    # @see UIAElementArray.withName()
    #
    def with_name(name)
      element_array_proxy_for :withName, name
    end

    # Returns a proxy to the first element with the given name.
    # 
    # @param [String] name
    # @return [UIAutomation::Element] the element proxy
    # @see UIAElementArray.firstWithName()
    #
    def first_with_name(name)
      element_proxy_for :firstWithName, name
    end

    # Returns a new ElementArray containing all elements matching the given predicate.
    #
    # Predicates use the Apple NSPredicate syntax.
    #
    # To avoid dealing with escaping and quoting of string values, you can use template substitution
    # in your predicate string and pass in the values as a hash.
    #
    # @example Using predicate template substitution
    #     array.with_predicate("name beginswith :value", :value => 'test')
    # 
    # @param [String] template a predicate template using NSPredicate syntax
    # @param [Hash] substitutions an optional hash of template substitutions
    # @return [UIAutomation::ElementArray] a sub-set of the current element array
    # @see UIAElementArray.withPredicate()
    # @see https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Predicates/Articles/pSyntax.html
    #
    def with_predicate(template, substitutions = {})
      element_array_proxy_for :withPredicate, UIAutomation::PredicateString.new(template, substitutions).to_s
    end

    # Returns a proxy to the first element matching the specified predicate.
    #
    # Predicates use the Apple NSPredicate syntax (see #with_predicate for more information).
    #
    # @param [String] template a predicate template using NSPredicate syntax
    # @param [Hash] substitutions an optional hash of template substitutions
    # @return [UIAutomation::Element] the element proxy
    # @see #with_predicate
    # @see UIAElementArray.firstWithPredicate()
    #
    def first_with_predicate(template, substitutions = {})
      element_proxy_for :firstWithPredicate, UIAutomation::PredicateString.new(template, substitutions).to_s
    end

    # Returns a new ElementArray containing all elements with the given key/value pair.
    # 
    # @param [String] key 
    # @param [Object] value
    # @return [UIAutomation::ElementArray] a sub-set of the current element array
    # @see UIAElementArray.withValueForKey()
    #
    def with_value_for_key(key, value)
      element_array_proxy_for :withValueForKey, value, key
    end

    # Returns a new ElementArray containing all elements with the given value.
    # 
    # @param [Object] value
    # @return [UIAutomation::ElementArray] a sub-set of the current element array
    #
    def with_value(value)
      with_value_for_key(:value, value)
    end

    # Returns a proxy to the first element with the given value.
    # 
    # @param [Object] value the element value
    # @return [UIAutomation::Element] the element proxy or nil if no elements found
    # @see UIAElementArray.firstWithName()
    #
    def first_with_value(value)
      collection = with_value(value)
      collection.any? ? collection.first : nil
    end
    
    # Returns a remote proxy to a specific element within the collection by index or name.
    #
    # You can use square-bracked syntax with either an Integer or String key to perform lookup
    # by index or name respectively.
    #
    # Calling with an Integer is equivalent to calling #at_index. Calling with a String is
    # equivalent to calling #first_with_name.
    # 
    # @param [String or Integer] index_or_name the index or name of the attribute
    # @return [UIAutomation::Element] the matching element
    # @see UIAElementArray.withName()
    #
    def [](index_or_name)
      if index_or_name.is_a?(Integer)
        at_index(index_or_name)
      else
        first_with_name(index_or_name)
      end
    end
    
    ### @!endgroup

    # Returns the number of items in the array
    # @return [Integer]
    #
    def length
      fetch(:length)
    end
    alias :count :length

    # Yields a proxy to each element in the ElementArray if a block is given.
    #
    # If no block is given, this method will return an Enumerator.
    #
    # @yieldparam [UIAutomation::Element] element if block given
    # @return [Enumerator] if no block is given
    #
    def each(&block)
      if block_given?
        (0...length).each do |index|
          yield self[index]
        end
      else
        to_enum(:each)
      end
    end

    private

    def element_proxy_for(function_name, *function_args)
      proxy_for(function_name,
        function_args: function_args,
        proxy_klass: @element_klass,
        proxy_args: [parent, window]
      )
    end

    def element_array_proxy_for(function_name, *function_args)
      proxy_for(function_name,
        function_args: function_args,
        proxy_klass: UIAutomation::ElementArray,
        proxy_args: [element_klass, parent, window]
      )
    end
  end

  # @private
  class PredicateString
    def initialize(template, substitutions = {})
      @template = template
      @substitutions = substitutions
    end

    def to_s
      @substitutions.reduce(@template) do |string, (key, value)|
        string.gsub(/:#{key}/, escaped(value))
      end
    end

    private

    def escaped(value)
      if value.is_a?(String)
        "\"#{value}\""
      else
        value.to_s
      end
    end
  end
end

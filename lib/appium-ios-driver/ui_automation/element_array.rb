module UIAutomation
  class ElementArray < RemoteProxy
    include Enumerable
    
    attr_reader :parent, :window, :element_klass

    def initialize(driver, remote_object, element_klass = UIAutomation::Element, parent_element = nil, window = nil)
      super driver, remote_object
      @element_klass = element_klass
      @parent = parent_element
      @window = window
    end

    def inspect
      "<RemoteProxy(#{self.class.name}) type:#{element_proxy_for}: #{to_javascript}>"
    end

    def at_index(index)
      element_proxy_for remote_object.object_for_subscript(index)
    end

    def with_name(name)
      element_array_proxy_for remote_object.object_for_function(:withName, name)
    end

    def first_with_name(name)
      element_proxy_for remote_object.object_for_function(:firstWithName, name)
    end

    def with_predicate(template, subtitutions)
      element_array_proxy_for remote_object.object_for_function(:withPredicate,
        UIAutomation::PredicateString.new(template, subtitutions).to_s)
    end

    def first_with_predicate(template, subtitutions)
      element_proxy_for remote_object.object_for_function(:firstWithPredicate,
        UIAutomation::PredicateString.new(template, subtitutions).to_s)
    end
    
    def with_value_for_key(key, value)
      element_array_proxy_for remote_object.object_for_function(:withValueForKey, value, key)
    end
    
    def with_value(value)
      with_value_for_key(:value, value)
    end
    
    def first_with_value(value)
      collection = with_value(value)
      collection.any? ? collection.first : nil
    end

    def length
      fetch(:length)
    end
    alias :count :length

    def [](index_or_name)
      if index_or_name.is_a?(Integer)
        at_index(index_or_name)
      else
        first_with_name(index_or_name)
      end
    end

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

    def element_proxy_for(remote_object)
      @element_klass.new(@driver, remote_object, @parent, @window)
    end
    
    def element_array_proxy_for(remote_object)
      UIAutomation::ElementArray.new(@driver, remote_object, @element_klass, @parent, @window)
    end
  end

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

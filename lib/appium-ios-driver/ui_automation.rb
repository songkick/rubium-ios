require 'active_support/core_ext/string/inflections'
require 'json'

module UIAutomation
  class RemoteProxy
    attr_reader :remote_object

    class << self
      attr_accessor :debug_on_exception
    end

    def initialize(driver, remote_object)
      @driver = driver
      @remote_object = remote_object
      raise "Remote object cannot be a string!" if remote_object.is_a?(String)
    end

    def self.from_javascript(driver, javascript, *args)
      new(driver, RemoteJavascriptObject.new(javascript), *args)
    end

    def self.from_element_id(driver, element_id, *args)
      new(driver, RemoteObjectByElementID.new(element_id), *args)
    end

    # Returns a new proxy object to the object returned from the method that corresponds
    # to the object returned by calling function_name on the currently proxied object, e.g.
    # if the current proxy represents the object UIATarget.localTarget() and
    # you call this method with :frontMostApp, it will return a proxy to the object
    # represented in the Javascript API by UIATarget.localTarget().frontMostApp().
    #
    def proxy_for(function_name, function_args: [], proxy_klass: RemoteProxy, proxy_args: [])
      proxy_klass.new(@driver, remote_object.object_for_function(function_name, *function_args), *proxy_args)
    end

    # Returns a new proxy object to a UIAElementArray. function_name must correspond to
    # a function on the currently proxied object that returns an UIAElementArray as 
    # defined by the Javascript API documentation.
    #
    # By default, the returned object will use UIAutomation::Element when creating
    # proxies to any elements within its collection - pass a different UIAutomation::Element
    # sub-class in as a second parameter if you want to use a specific type.
    #
    def element_array_proxy_for(function_name, element_klass = UIAutomation::Element)
      proxy_for(function_name, UIAutomation::ElementArray, element_klass, self, window)
    end

    # Similar to proxy_for() but returns an instance UIAutomation::Element by default.
    #
    # A specific UIAutomation::Element sub-class can be passed in as an optional second
    # parameter.
    #
    def element_proxy_for(function_name, klass = UIAutomation::Element)
      proxy_for(function_name, klass, self, window)
    end

    # Alias for proxy_for(). If you need a specific sub-class of UIAutomation::Element, 
    # you should use proxy_for() instead.
    #
    def [](function_name)
      element_proxy_for(function_name)
    end

    def to_s
      to_javascript
    end
    
    def inspect
      "<RemoteProxy(#{self.class.name}): #{to_javascript}>"
    end

    # Returns the Javascript UIAutomation API representation of the current object
    #
    def to_javascript
      @remote_object.javascript
    end
    alias :javascript :to_javascript

    # Performs a function on the current Javascript object and returns the raw value.
    #
    # This is useful for any methods that return values like strings, hashes and numbers.
    #
    # If you use this to call a method that would normally return another Javascript object
    # (like an element), this will simply return an empty hash. You should use one of the
    # proxy objects above instead to return a new proxy to that object.
    #
    def perform(function, *args)
      @driver.execute_script(remote_object.object_for_function(function, *args).javascript)
    rescue StandardError => e
      binding.pry if self.class.debug_on_exception
      raise "Error performing javascript: #{javascript} (server error: #{e})"
    end

    def fetch(property)
      @driver.execute_script(remote_object.object_for_property(property).javascript)
    rescue StandardError => e
      binding.pry if self.class.debug_on_exception
      raise "Error performing javascript: #{javascript} (server error: #{e})"
    end

    def execute_self
      @driver.execute_script(remote_object.javascript)
    end

    # Represents a remote javascript object using raw javascript, e.g.
    # to represent the main application, you would initialize this with 
    # the string 'UIATarget.currentTarget().frontMostApp()'
    #
    class RemoteJavascriptObject
      def initialize(javascript)
        @javascript = javascript
      end

      def javascript
        @javascript
      end

      def to_s
        javascript
      end

      def object_for_function(function_name, *args)
        RemoteJavascriptObject.new("#{javascript}.#{function_name}(#{format_args(args)})")
      end

      def object_for_subscript(subscript)
        RemoteJavascriptObject.new("#{javascript}[#{format_arg(subscript)}]")
      end

      def object_for_property(property_name)
        RemoteJavascriptObject.new("#{javascript}.#{property_name}")
      end

      def format_arg(arg)
        case arg
          when String, Symbol
            "'#{arg}'"
          when Hash
            arg.to_json
          when Array
            arg.to_json
          else
            arg
        end
      end

      def format_args(args)
        args.map { |arg| format_arg(arg) }.join(", ")
      end
    end

    # Represents a remote javascript object by element ID, where element ID
    # is the ID of a Selenium::WebDriver::Element returned by one of the built-in
    # Selenium finder methods.
    #
    # This allows us to construct remote proxies to javascript objects that are found
    # using e.g. an xpath without having to know the actual index path to the object
    # in the UIAutomation javascript object tree.
    #
    class RemoteObjectByElementID < RemoteJavascriptObject
      def initialize(object_id)
        @object_id = object_id
      end

      def javascript
        # this uses internal APIs provided by appium-auto
        "au.getElement(#{@object_id})"
      end
    end

    private

    # We override method_missing so you can dynamically call methods that correspond to 
    # methods in the Javascript API without having to explicitly call perform().
    #
    # As with perform(), this should only be used for methods that return values rather 
    # than other objects.
    #
    # You can call methods in the Javascript API using snake_case or lowerCamelCase - all
    # snake case methods will automatically be transformed into the Javascript lowerCamelCase
    # equivalent (e.g. text_fields -> textFields).
    #
    def method_missing(method, *args, &block)
      perform(method.to_s.camelize(:lower), *args)
    end

    def window
      nil
    end
  end

  # require 'proxies/element_definitions'
  # 
  # module UIAutomation
  #   # to avoid circular dependency
  #   class Element < RemoteProxy
  #     extend ElementDefinitions
  #   end
  # 
  #   class NoSuchElement
  #     def method_missing(method, *args, &block)
  #       if UIAutomation::Element.method_defined?(method)
  #         return nil
  #       else
  #         warn "Tried to call #{method} on NoSuchElement"
  #         super
  #       end
  #     end
  #   end
  # end
  # 
  # require 'proxies/element_array'
  # require 'proxies/element'
  
  autoload :Element, 'ui_automation/element'
end

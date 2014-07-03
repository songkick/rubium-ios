require 'active_support/core_ext/string/inflections'
require 'json'

module UIAutomation
  class RemoteProxy
    attr_reader :remote_object

    class << self
      attr_accessor :debug_on_exception
    end

    def initialize(executor, remote_object_or_string)
      @executor = executor
      @remote_object = remote_object_from(remote_object_or_string)
    end

    def self.from_javascript(executor, javascript, *args)
      new(executor, RemoteJavascriptObject.new(javascript), *args)
    end

    def self.from_element_id(executor, element_id, *args)
      new(executor, RemoteObjectByElementID.new(element_id), *args)
    end

    # Returns a new proxy object to the object returned from the method that corresponds
    # to the object returned by calling function_name on the currently proxied object, e.g.
    # if the current proxy represents the object UIATarget.localTarget() and
    # you call this method with :frontMostApp, it will return a proxy to the object
    # represented in the Javascript API by UIATarget.localTarget().frontMostApp().
    #
    def proxy_for(function_name, function_args: [], proxy_klass: RemoteProxy, proxy_args: [])
      build_proxy(proxy_klass, remote_object.object_for_function(function_name, *function_args), proxy_args)
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
      @executor.execute_script(remote_object.object_for_function(function, *args).javascript)
    rescue StandardError => e
      binding.pry if self.class.debug_on_exception
      raise "Error performing javascript: #{javascript} (server error: #{e})"
    end

    def fetch(property)
      @executor.execute_script(remote_object.object_for_property(property).javascript)
    rescue StandardError => e
      binding.pry if self.class.debug_on_exception
      raise "Error performing javascript: #{javascript} (server error: #{e})"
    end

    def execute_self
      @executor.execute_script(remote_object.javascript)
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
    
    def remote_object_from(remote_object_or_string)
      if remote_object_or_string.is_a?(String)
        RemoteJavascriptObject.new(remote_object_or_string)
      elsif remote_object_or_string.is_a?(RemoteJavascriptObject)
        remote_object_or_string
      else
        raise TypeError.new("Remote object must be a RemoteJavascriptObject or String, but was #{remote_object_or_string.class}")
      end
    end

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
    
    def build_proxy(proxy_klass, remote_object, proxy_args)
      proxy_klass.new(@executor, remote_object, *proxy_args)
    end
  end

  class NoSuchElement
    def method_missing(method, *args, &block)
      if UIAutomation::Element.method_defined?(method)
        return nil
      else
        warn "Tried to call #{method} on NoSuchElement"
        super
      end
    end
  end
  
  require 'ui_automation/element_definitions'
  
  autoload :Element,        'ui_automation/element'
  autoload :ElementArray,   'ui_automation/element_array'
  autoload :Application,    'ui_automation/application'
  autoload :Window,         'ui_automation/window'
  autoload :TableView,      'ui_automation/table_view'
  autoload :TabBar,         'ui_automation/tab_bar'
  autoload :NavigationBar,  'ui_automation/navigation_bar'
  autoload :TextField,      'ui_automation/text_field'
  autoload :Keyboard,       'ui_automation/keyboard'
  autoload :Target,         'ui_automation/target'
  autoload :Logger,         'ui_automation/logger'
end

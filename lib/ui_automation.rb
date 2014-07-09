require 'active_support/core_ext/string/inflections'
require 'json'

module UIAutomation
  # RemoteProxy acts as a proxy or facade to Appium's ability to remotely execute 
  # Javascript within the Instruments runtime environment.
  #
  # Rather than having to manual build strings of Javascript using the Apple UIAutomation
  # API and executing them using Appium::IOSDriver#execute, you can use a RemoteProxy as 
  # if it was an instance of a Javascript object within the UIAutomation API.
  #
  # You can fetch values of properties, perform methods and obtain new proxies to objects
  # returned by a Javascript method.
  #
  # As well as providing explicit APIs for fetching properties and performing methods,
  # you can also use square-bracket notation for accessing properties and for methods, 
  # you can just call them on the proxy as if they were Ruby methods. You can perform
  # any method that is defined in the UIAutomation API and you can also use underscore_case
  # - it will automatically be converted to `lowerCamelCase`.
  #
  # Generally, you wouldn't use this directly but would instead use one of the sub-classes
  # within the library: the Ruby mirror of the UIAutomation Javascript API is built on top
  # of this class.
  #
  # @example Fetch the 'model' from the local target
  #     executor = Appium::IOSDriver.new(capabilities)
  #     target = UIAutomation::RemoteProxy.new(executor, "UIATarget.localTarget()")
  #     puts target.model # => 'iOS Simulator'
  #
  # @example Set the simulator location on the local target
  #     target = UIAutomation::RemoteProxy.new(executor, "UIATarget.localTarget()")
  #     target.set_location(lat: 90.0, lng: -10.0)
  #
  # @example Print the rect of the main window
  #     target = UIAutomation::RemoteProxy.new(executor, "UIATarget.localTarget()")
  #     application = target.proxy_for(:frontMostApp)
  #     main_window = application.proxy_for(:mainWindow)
  #     puts main_window.rect
  # 
  class RemoteProxy
    class << self
      attr_accessor :debug_on_exception
    end

    # Creates a new RemoteProxy instance.
    #
    # Generally, the executor param will be an instance of `Appium::IOSDriver` but it 
    # can be any object that responds to `#execute(string)` and is able to execute the
    # Javascript remotely using the Selenium web-driver protocol.
    #
    # A string of Javascript can be passed as the second parameter and it will automatically be
    # converted into an instance of `RemoteJavascriptObject`.
    #
    # @note Use the factory methods `from_javascript` or `from_element_id` instead
    # @api private
    # @param [<Object#execute>] executor An object that can execute remote Javascript
    # @param [String, RemoteJavascriptObject] remote_object_or_string A Javascript representation of the object to be proxied.
    #
    def initialize(executor, remote_object_or_string)
      @executor = executor
      @remote_object = remote_object_from(remote_object_or_string)
    end
    
    ### @!group Factory methods

    # Returns a new RemoteProxy instance from a string of Javascript.
    #
    # @see #initialize 
    #
    def self.from_javascript(executor, javascript, *args)
      new(executor, RemoteJavascriptObject.new(javascript), *args)
    end

    # Returns a new RemoteProxy instance from an Appium element ID.
    #
    # @note This method uses Appium's own internal element IDs returned from an XPath
    # query and should not be used directly.
    #
    # @see #initialize
    # @see Appium::IOSDriver#find
    #
    def self.from_element_id(executor, element_id, *args)
      new(executor, RemoteObjectByElementID.new(element_id), *args)
    end
    
    ### @!endgroup
    
    ### @!group Proxy Methods    

    # Returns a new proxy to the Javascript object returned from the method called on the object
    # represented by self.
    #
    # For instance, if the current proxy represents the object `UIATarget.localTarget()` and
    # you call this method with the method name :frontMostApp, it will return a proxy to the object
    # represented in the Javascript API by `UIATarget.localTarget().frontMostApp()`.
    #
    # @param [Symbol] function_name The Javascript method name that returns the object to be proxied
    # @param [Array] function_args Any arguments that should be passed to the Javascript method
    # @param [Class] proxy_klass The type of RemoteProxy class to use (must be a sub-class of RemoteProxy)
    # @param [Array] proxy_args Any additional arguments required to initialize a specific RemoteProxy sub-class.
    # @raise `TypeError` if proxy_klass is not a valid sub-class of RemoteProxy
    # @return [RemoteProxy] default return type
    # @return [proxy_klass] if specified
    #
    def proxy_for(function_name, function_args: [], proxy_klass: RemoteProxy, proxy_args: [])
      raise TypeError.new("proxy_klass must be a RemoteProxy or sub-class") unless proxy_klass <= RemoteProxy
      build_proxy(proxy_klass, remote_object.object_for_function(function_name, *function_args), proxy_args)
    end

    # Performs a function on the current Javascript object and returns the raw value.
    #
    # This is useful for any methods that return values like strings, hashes and numbers.
    #
    # If you use this to call a method that would normally return another Javascript object
    # this will simply return an empty hash. Use `#proxy_for` to return  a new proxy to 
    # another Javascript object instead.
    #
    # @param [Symbol] function The name of the Javascript method to call on the object represented by self
    # @param [args] args A list of arguments to be passed to the Javascript method
    # @see #method_missing 
    #
    def perform(function, *args)
      @executor.execute_script(remote_object.object_for_function(function, *args).javascript)
    rescue StandardError => e
      binding.pry if self.class.debug_on_exception
      raise "Error performing javascript: #{javascript} (server error: #{e})"
    end

    # Fetches the value of the named property on the current Javascript object.
    #
    # @param [Symbol] property The name of the property to return 
    # @return [Object] The Ruby equivalent of whatever the Javascript method returns.
    #
    def fetch(property)
      @executor.execute_script(remote_object.object_for_property(property).javascript)
    rescue StandardError => e
      binding.pry if self.class.debug_on_exception
      raise "Error performing javascript: #{javascript} (server error: #{e})"
    end
    
    # Can be used as an alternative to calling #fetch
    # @see #fetch
    #
    def [](property)
      fetch(property)
    end

    # @api private
    def execute_self
      @executor.execute_script(remote_object.javascript)
    end
    
    ### @!endgroup
    
    ### @!group Debugging
    
    # Returns the Javascript representation
    # @return [String]
    # @see #to_javascript
    #
    def to_s
      to_javascript
    end
    
    
    def inspect
      "<RemoteProxy(#{self.class.name}): #{to_javascript}>"
    end

    # @return [String] the Javascript representation of the proxied object
    #
    def to_javascript
      @remote_object.javascript
    end
    alias :javascript :to_javascript
    
    ### @!endgroup

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
          when Hash, Array
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

    # RemoteProxy lets you call methods that correspond to 
    # methods in the Javascript API without having to explicitly call perform().
    #
    # As with perform(), this should only be used for methods that return values rather 
    # than other objects.
    #
    # You can call methods in the Javascript API using snake_case or lowerCamelCase - all
    # snake case methods will automatically be transformed into the Javascript lowerCamelCase
    # equivalent (e.g. text_fields -> textFields).
    #
    # @param [Symbol] method will be converted to lowerCamelCase and used as the first argument to #perform
    # @param [Array] args any arguments will be passed as arguments to the Javascript function
    # @see #perform
    #
    def method_missing(method, *args, &block)
      perform(method.to_s.camelize(:lower), *args)
    end

    def window
      nil
    end
    
    def remote_object
      @remote_object
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
  autoload :Picker,         'ui_automation/picker'
  autoload :Popover,        'ui_automation/popover'
  autoload :TextView,       'ui_automation/text_view'
  autoload :ActivityView,   'ui_automation/activity_view'
  autoload :ActionSheet,    'ui_automation/action_sheet'
  
  module Traits
    autoload :Cancellable,  'ui_automation/traits/cancellable'
  end
end

require 'appium/session'

module Appium
  class IOSDriver
    attr_accessor :implicit_timeout
    
    DEFAULT_SESSION_TIMEOUT = 30

    def initialize(capabilities, host = Appium.default_host, port = Appium.default_port)
      @capabilities = capabilities
      @host = host
      @port = port
      @implicit_timeout = 1
    end

    def launch(session_timeout = DEFAULT_SESSION_TIMEOUT)
      @session ||= Appium::Session.new(@host, @port, @capabilities, session_timeout)
      update_implicit_timeout(implicit_timeout)
      self.native_timeout = implicit_timeout
    end

    def quit
      @session.terminate if @session
      @session = nil
    end

    def with_session(session_timeout = DEFAULT_SESSION_TIMEOUT, &block)
      raise "Session already running!" if @session
      launch(session_timeout)
      begin
        yield @session if block_given?
      ensure
        quit
      end
    end

    def relaunch
      quit
      launch
    end

    def self.instruments_environment_variables(env)
      env.empty? ? "" : env.map { |key, value| "-e #{key} #{value}" }.join(" ")
    end
    
    ### @!group Managing timeouts
    
    # Sets the implicit timeout used by the underlying Selenium::WebDriver instance.
    #
    # Implicit timeouts are used when trying to find elements on the screen using the
    # low-level #find and #find_all methods. They do not affect any remotely executed
    # Javascript and therefore have no affect on code that uses the native Javascript
    # proxy APIs.
    #
    # @param [Numeric] value The new timeout value, in seconds
    # 
    def implicit_timeout=(value)
      @implicit_timeout = value
      update_implicit_timeout(implicit_timeout)
    end
    
    # Temporarily sets the implicit timeout to the given value and invokes the block.
    #
    # After the block has been invoked, the original timeout will be restored.
    #
    # @param [Numeric] timeout The temporary timeout, in seconds
    #
    def with_implicit_timeout(timeout, &block)
      update_implicit_timeout(timeout)
      yield
      update_implicit_timeout(implicit_timeout)
    end

    # Returns the native Javascript API implicit timeout
    # @see UIATarget.timeout()
    #
    def native_timeout
      target.timeout
    end

    # Sets the native Javascript API implicit timeout
    # @param [Numeric] new_timeout The new timeout, in seconds
    # @see UIATarget.setTimeout()
    # 
    def native_timeout=(new_timeout)
      target.setTimeout(new_timeout)
    end

    # Temporarily sets the native Javascript API implicit timeout by pushing a new
    # timeout on to the timeout stack, calling the given block and then popping the
    # timeout off the stack.
    #
    # @param [Numeric] value The temporary timeout, in seconds
    # @see UIATarget.pushTimeout(), UIATarget.popTimeout()
    #
    def with_native_timeout(value, &block)
      target.pushTimeout(value)
      yield if block_given?
      target.popTimeout
    end
    
    # Performs an explicit wait until the given block returns true.
    #
    # You can use this method to wait for an explicit condition to occur
    # before continuing.
    #
    # @example
    #     driver.wait_until { something_happened }
    # 
    # @param [Numeric] timeout The explicit wait timeout, in seconds
    # @param [Numeric] interval The interval to wait between retries.
    # @yieldreturn [Boolean] The block will be repeatedly called up to the timeout until it returns true.
    #
    def wait_until(timeout: 1, interval: 0.2, &block)
      Selenium::WebDriver::Wait.new(timeout: upto, interval: interval).until(&block)
    end

    ### @!endgroup

    def find(xpath)
      element_proxy_for driver.find_element(:xpath, xpath)
    rescue Selenium::WebDriver::Error::NoSuchElementError => e
      UIAutomation::NoSuchElement.new
    end

    def find_all(xpath)
      driver.find_elements(:xpath, xpath)
    end

    def capture_screenshot(output_file, format = :png)
      File.open(output_file, 'wb') { |io| io.write driver.screenshot_as(format) }
    end

    def target
      @target ||= UIAutomation::Target.local_target(self)
    end

    def logger
      @logger ||= UIAutomation::Logger.logger(self)
    end
    
    def execute_script(script)
      driver.execute_script(script)
    end
    alias :execute :execute_script

    private

    def update_implicit_timeout(value)
      driver.manage.timeouts.implicit_wait = value if @session
    end
    
    def driver
      raise "You must call #launch to start a session first!" unless @session
      @session.driver
    end

    ELEMENT_PROXY_MAPPING = {
      'UIAKeyboard'         => UIAutomation::Keyboard,
      'UIATabBar'           => UIAutomation::TabBar,
      'UIATableView'        => UIAutomation::TableView,
      'UIATextField'        => UIAutomation::TextField,
      'UIASecureTextField'  => UIAutomation::TextField,
      'UIASearchBar'        => UIAutomation::TextField,
      'UIAWindow'           => UIAutomation::Window,
      'UIANavigationBar'    => UIAutomation::NavigationBar,
      'UIAActionSheet'      => UIAutomation::ActionSheet,
      'UIAActivityView'     => UIAutomation::ActivityView,
      'UIAPicker'           => UIAutomation::Picker,
      'UIAPopover'          => UIAutomation::Popover,
      'UIATextView'         => UIAutomation::TextView
    }

    def element_proxy_for(element)
      proxy_klass = ELEMENT_PROXY_MAPPING[element.tag_name] || UIAutomation::Element
      proxy_klass.from_element_id(driver, element.ref, nil, nil)
    end
  end
end

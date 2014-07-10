require 'appium/session'

module Appium
  class IOSDriver
    attr_accessor :implicit_timeout
    
    # The default session timeout, in seconds
    DEFAULT_SESSION_TIMEOUT = 30

    def initialize(capabilities, host = Appium.default_host, port = Appium.default_port)
      @capabilities = capabilities
      @host = host
      @port = port
      @implicit_timeout = 1
    end
    
    ### @!group Session Management

    # Launches a new Appium session.
    #
    # Launching a new Appium session will cause Appium to launch Instruments, which 
    # in turn will launch your application in the simulator or on your device.
    #
    # @param [Numeric] session_timeout the underlying HTTP session timeout, in seconds
    # @raise Appium::Session::ConnectionError if could not connect to the server.
    #
    def launch(session_timeout = DEFAULT_SESSION_TIMEOUT)
      @session ||= Appium::Session.new(@host, @port, @capabilities, session_timeout)
      update_implicit_timeout(implicit_timeout)
      self.native_timeout = implicit_timeout
    end

    # Quits the current session, if there is one.
    #
    # When you quit a session, Appium will terminate the Instruments process which will 
    # in turn kill the iOS simulator or remove the app from your device.
    #
    def quit
      @session.terminate if @session
      @session = nil
    end

    # Launches a new session, calls the given block, then quits.
    #
    # This method lets you treat a session as a transaction, with the given block being
    # executed after launching then quitting the session when the block returns. 
    #
    # Using this method ensures you do not have to explicitly quit the session when you
    # are finished.
    #
    # This method will quit the session after the block has finished executing, even if
    # the block raises an exception.
    #
    # @param [Numeric] session_timeout the underlying HTTP session timeout, in seconds
    # @raise RuntimeError if a session is already running
    #
    def with_session(session_timeout = DEFAULT_SESSION_TIMEOUT, &block)
      raise "Session already running!" if @session
      launch(session_timeout)
      begin
        yield @session if block_given?
      ensure
        quit
      end
    end

    # Quits any existing session before launching a new one.
    #
    def relaunch
      quit
      launch
    end

    ### @!endgroup
    
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
    
    ### @!group Javascript Proxy Methods
    
    # Returns a proxy to the local target (UIATarget).
    #
    # This method is the main entry point into the UIAutomation Javascript proxy API.
    # The local target is the root object in the UIAutomation object graph.
    #
    # @return [UIAutomation::Target] A proxy to the local target (UIATarget.localTarget())
    #
    def target
      @target ||= UIAutomation::Target.local_target(self)
    end

    # Returns a proxy to the native UIAutomation logger.
    #
    # @return [UIAutomation::Logger] 
    def logger
      @logger ||= UIAutomation::Logger.logger(self)
    end
    
    # Executes a string of Javascript within the Instruments process.
    #
    # @param [String] script the Javascript to be executed.
    # @raise Selenium::WebDriver::Error::JavascriptError if the evaluated Javascript errors.
    # @note This method will always return immediately in the case of an error, regardless of# any implicit or native timeout set. If you need to execute some Javascript until it is  successful, you should consider using an explicit wait.
    #
    def execute_script(script)
      driver.execute_script(script)
    end
    alias :execute :execute_script

    ### @!endgroup

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

require 'appium/session'

module Appium
  class IOSDriver
    attr_accessor :implicit_timeout

    def initialize(capabilities, host = Appium.default_host, port = Appium.default_port)
      @capabilities = capabilities
      @host = host
      @port = port
      @implicit_timeout = 1
    end

    def implicit_timeout=(value)
      @implicit_timeout = value
      update_implicit_timeout(implicit_timeout)
    end

    def launch(session_timeout = 30)
      @session ||= Appium::Session.new(@host, @port, @capabilities, session_timeout)
      update_implicit_timeout(implicit_timeout)
      self.native_timeout = implicit_timeout
    end

    def quit
      @session.terminate if @session
      @session = nil
    end

    def with_session(&block)
      raise "Session already running!" if @session
      launch
      yield @session if block_given?
      quit
    end

    def relaunch
      quit
      launch
    end

    def self.instruments_environment_variables(env)
      env.empty? ? "" : env.map { |key, value| "-e #{key} #{value}" }.join(" ")
    end

    def with_implicit_timeout(timeout, &block)
      update_implicit_timeout(timeout)
      yield
      update_implicit_timeout(implicit_timeout)
    end

    def native_timeout
      target.timeout
    end

    def native_timeout=(new_timeout)
      target.setTimeout(new_timeout)
    end

    def with_native_timeout(value, &block)
      target.pushTimeout(value)
      yield if block_given?
      target.popTimeout
    end

    def wait_for_keyboard
      driver.find_element(:xpath, "//UIAKeyboard")
    end

    def execute(script)
      driver.execute_script(script)
    end

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
      @target ||= UIAutomation::Target.local_target(driver)
    end

    def logger
      @logger ||= UIAutomation::Logger.logger(driver)
    end

    def front_most_app
      target.proxy_for(:frontMostApp)
    end

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
    }

    def element_proxy_for(element)
      proxy_klass = ELEMENT_PROXY_MAPPING[element.tag_name] || UIAutomation::Element
      proxy_klass.from_element_id(driver, element.ref, nil, nil)
    end
  end
end

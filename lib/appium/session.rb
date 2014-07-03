require 'selenium-webdriver'

module Appium
  class Session
    attr_reader :driver

    def initialize(host, port, capabilities, timeout = 30)
      client = Selenium::WebDriver::Remote::Http::Default.new
      client.timeout = timeout

      @driver = Selenium::WebDriver.for(:remote,
        desired_capabilities: capabilities.to_hash,
        url: "http://#{host}:#{port}#{Appium.root_path}",
        http_client: client
      )
    end

    def terminate
      @driver.quit rescue nil
    end
  end
end

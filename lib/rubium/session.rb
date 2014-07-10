require 'selenium-webdriver'

module Rubium
  class Session
    attr_reader :driver

    def initialize(host, port, capabilities, timeout = 30)
      client = Selenium::WebDriver::Remote::Http::Default.new
      client.timeout = timeout

      @driver = Selenium::WebDriver.for(:remote,
        desired_capabilities: capabilities.to_hash,
        url: "http://#{host}:#{port}#{Rubium.root_path}",
        http_client: client
      )
    rescue Errno::ECONNREFUSED
      raise ConnectionError
    end

    def terminate
      @driver.quit rescue nil
    end
    
    class ConnectionError < RuntimeError; end
  end
end

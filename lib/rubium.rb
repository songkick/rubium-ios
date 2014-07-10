module Rubium
  class << self
    def default_host
      'localhost'
    end

    def default_port
      4723
    end

    def root_path
      "/wd/hub"
    end
  end
end

require 'ui_automation'
require 'ui_automation/element_proxy_methods'
require 'rubium'
require 'rubium/driver'
require 'rubium/capabilities'

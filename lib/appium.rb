module Appium
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

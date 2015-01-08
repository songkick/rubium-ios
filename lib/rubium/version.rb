module Rubium
  module Version
    MAJOR = 1
    MINOR = 0
    TINY  = 1

    def self.to_s
      version = [MAJOR, MINOR, TINY].join(".")
      prerelease ? "#{version}.pre" : version
    end

    def self.prerelease
      false
    end
  end
end

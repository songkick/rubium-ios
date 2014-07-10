module Rubium
  module Capabilities
    class Base
      LATEST_SDK_VERSION = '7.1'
      
      attr_accessor :platform_name
      attr_accessor :platform_version
      attr_accessor :device_name
      attr_accessor :new_command_timeout
      attr_accessor :app
      attr_accessor :bundle_id
      attr_accessor :launch_timeout
      attr_accessor :auto_accept_alerts
      attr_accessor :process_arguments
      
      def initialize(values = {}, &block)
        values.merge(default_values).each do |k, v|
          __send__("#{k}=", v) if respond_to?(k)
        end
        
        yield self if block_given?
      end
      
      def to_hash(additional_keys = {})
        without_nil_values additional_keys.merge({
          'platformName' => platform_name,
          'platformVersion' => platform_version,
          'deviceName' => device_name,
          'newCommandTimeout' => new_command_timeout,
          'app' => app,
          'bundleId' => bundle_id,
          'launchTimeout' => launch_timeout,
          'autoAcceptAlerts' => auto_accept_alerts,
          'processArguments' => process_arguments,
          'appium-version' => "1.0"
        })
      end
      
      private
      
      def without_nil_values(hash)
        hash.delete_if { |k, v| v.nil? }
      end
      
      def default_values
        {
          platform_name: 'iOS',
          platform_version: LATEST_SDK_VERSION,
          new_command_timeout: 30
        }
      end
    end
    
    class Simulator < Base
      attr_accessor :language
      attr_accessor :orientation
      attr_accessor :calendar_format
      attr_accessor :location_services_enabled
      attr_accessor :location_services_authorized
      
      def to_hash(additional_keys = {})
        super({
          'language' => language,
          'orientation' => orientation,
          'calendarFormat' => calendar_format,
          'locationServicesEnabled' => location_services_authorized,
          'locationServicesAuthorized' => location_services_authorized
        })
      end
      
      private
      
      def default_values
        super.merge({
          locale: 'en',
          orientation: 'PORTRAIT',
          device_name: 'iPhone Simulator'
        })
      end
    end
    
    class Device < Base
      attr_accessor :udid
      
      def to_hash(additional_keys = {})
        super({
          'udid' => udid
        })
      end
    end
  end
end

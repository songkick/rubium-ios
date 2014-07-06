module UIAutomation
  # A RemoteProxy to UIATarget objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIATargetClassReference/
  #
  class Target < RemoteProxy
    # Returns an instance of UIAutomation::Target that represents the singleton local target (UIATarget.localTarget()).
    # @return [UIAutomation::Target]
    #
    def self.local_target(executor)
      from_javascript(executor, 'UIATarget.localTarget()')
    end
    
    # Returns a proxy to the currently active app.
    # @return [UIAutomation::Application]
    #
    def front_most_app
      proxy_for(:frontMostApp, proxy_klass: UIAutomation::Application)
    end
    
    # Sets the current location (iOS Simulator only).
    # @param [Hash] coordinates A hash containing :lat and :lng keys.
    #
    def location=(coordinates)
      set_location(coordinates)
    end
    
    # Performs a tap on the element by tapping at the position
    # of the element's rect.
    #
    # The preferred method of tapping an element is to just 
    # call UIAutomation::Element#tap which calls the UIAElement tap() method
    # directly on the element but this can sometimes fail on 
    # certain elements - this method is provided as a fallback.
    #
    # @param [UIAutomation::Element] element The element to tap.
    #
    def tap_element(element)
      perform(:tap, element.rect)
    end
  end
end

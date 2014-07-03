module UIAutomation
  class Target < RemoteProxy
    def self.local_target(driver)
      from_javascript(driver, 'UIATarget.localTarget()')
    end
    
    def front_most_app
      proxy_for(:frontMostApp, proxy_klass: UIAutomation::Application)
    end
    
    def location=(coordinates)
      set_location(coordinates)
    end
    
    # Performs a tap on the element by tapping at the position
    # of the element's rect.
    #
    # The preferred method of tapping an element is to just 
    # call element.tap which calls the UIAElement tap() method
    # directly on the element but this can sometimes fail on 
    # certain elements - this method is provided as a fallback.
    #
    def tap_element(element)
      perform(:tap, element.rect)
    end
  end
end

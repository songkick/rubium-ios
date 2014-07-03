module UIAutomation
  class Keyboard < UIAutomation::Element
    def type(string)
      perform :typeString, string
    end
    
    def keys
      element_array_proxy_for(:keys)
    end
    
    def done_button
      buttons['Done']
    end
    
    def return_button
      buttons['Return']
    end
  end
end

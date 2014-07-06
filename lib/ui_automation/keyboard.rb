module UIAutomation
  class Keyboard < UIAutomation::Element
    has_element_array :keys
    
    def type(string)
      perform :typeString, string
    end
    
    def done_button
      buttons['Done']
    end
    
    def return_button
      buttons['Return']
    end
  end
end

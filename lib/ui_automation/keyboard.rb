module UIAutomation
  # A RemoteProxy to UIAKeyboard objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIAKeyboardClassReference/
  #
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

module UIAutomation
  # A RemoteProxy to UIAKeyboard objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIAKeyboardClassReference/
  #
  class Keyboard < Element
    ### @!group Element Collections

    # The keyboard's keys
    has_element_array :keys

    ### @!endgroup
    
    ### @!group Elements

    # @return [UIAutomation::Element] the keyboard's done button
    def done_button
      buttons['Done']
    end
    
    # @return [UIAutomation::Element] the keyboard's return button
    def return_button
      buttons['Return']
    end

    ### @!endgroup
   
    ### @!group Actions

    # Types the given string by simulating key presses.
    #
    # @param [String] string the string to type
    #
    def type(string)
      perform :typeString, string
    end

    ### @!endgroup
  end
end

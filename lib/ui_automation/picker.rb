module UIAutomation
  # A RemoteProxy to UIAPicker objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIAPickerClassReference/
  #
  class Picker < Element
    ### @!group Element Collections

    # An array representing each wheel in the picker
    has_element_array :wheels

    ### @!endgroup
  end
end

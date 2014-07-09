module UIAutomation
  # A RemoteProxy to UIATextField objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIATextFieldClassReference/
  #
  class TextField < Element
    include Traits::TextInput
  end
end

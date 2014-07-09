module UIAutomation
  # A RemoteProxy to UIATextView objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIATextViewClassReference/
  #
  class TextView < Element
    include Traits::TextInput
  end
end

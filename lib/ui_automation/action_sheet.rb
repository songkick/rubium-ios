module UIAutomation
  # A RemoteProxy to UIAActionSheet objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIAActionSheetClassReference/
  #
  class ActionSheet < Element
    include Traits::Cancellable
  end
end

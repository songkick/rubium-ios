module UIAutomation
  # A RemoteProxy to UIAActivityView objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIActivityViewClassReference/
  #
  class ActivityView < Element
    include Traits::Cancellable
  end
end

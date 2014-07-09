module UIAutomation
  # A RemoteProxy to UIAAlert objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIAAlertSheetClassReference/
  #
  class Alert < Element
    include Traits::Cancellable
    
    ### @!group Elements

    # The alert's default button
    has_element :defaultButton
      
    ### @!endgroup
  end
end

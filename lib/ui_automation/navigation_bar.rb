module UIAutomation
  # A RemoteProxy to UIANavigationBar objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIANavigationBarClassReference/
  #
  class NavigationBar < Element
    ### @!group Elements

    # The navigation bar's left button
    has_element :leftButton
    
    # The navigation bar's right button
    has_element :rightButton

    ### @!endgroup    
  end
end

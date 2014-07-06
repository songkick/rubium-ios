module UIAutomation
  # A RemoteProxy to UIANavigationBar objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIANavigationBarClassReference/
  #
  class NavigationBar < UIAutomation::Element
    has_element :leftButton
    has_element :rightButton
  end
end

module UIAutomation
  # A RemoteProxy to UIATabBar objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIATabBarClassReference/
  #
  class TabBar < UIAutomation::Element
    has_element :selectedButton
    
    alias :tabs :buttons
    
    def tap_tab(tab_name)
      tabs[tab_name].tap
    end
  end
end

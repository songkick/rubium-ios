module UIAutomation
  # A RemoteProxy to UIATabBar objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIATabBarClassReference/
  #
  class TabBar < Element
    ### @!group Elements

    # The currently selected tab
    has_element :selectedButton

    ### @!endgroup

    def tabs
      buttons
    end
    
    alias_method :selected_tab, :selected_button

    ### @!group Actions

    # Selects the named tab
    # @param [String] tab_name the tab's label
    #
    def tap_tab(tab_name)
      tabs[tab_name].tap
    end

    ### @!endgroup
  end
end

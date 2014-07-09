module UIAutomation
  class Popover < Element
    ### @!group Elements

    # The action sheet contained by the popover
    has_element :actionSheet, type: UIAutomation::ActionSheet
    
    # The navigation bar contained by the popover
    has_element :navigationBar, type: UIAutomation::NavigationBar
    
    # The tab bar contained by the popover
    has_element :tabBar, type: UIAutomation::TabBar
    
    # The toolbar contained by the popover
    has_element :toolbar

    ### @!endgroup
  end
end

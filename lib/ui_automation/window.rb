module UIAutomation
  # A RemoteProxy to UIAWindow objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIAWindowClassReference/
  #
  class Window < UIAutomation::Element
    # @!group Elements

    # The main tab bar.
    #
    # On an iPhone there will normally only be one tab bar but an iPad may have multiple.
    has_element :tabBar, type: UIAutomation::TabBar
    
    # The main navigation bar.
    #
    # On an iPhone there will normally only be one navigation bar but an iPad may have multiple.
    has_element :navigationBar, type: UIAutomation::NavigationBar
    
    # The main toolbar.
    # 
    # On an iPhone there will normally only be one toolbar but an iPad may have multiple.
    has_element :toolbar
    
    # The first UITableView in the view hierarchy
    # @return [UIAutomation::TableView]
    #
    def main_table_view
      table_views[0]
    end

    # The first UIWebView in the view hierarchy
    # @return [UIAutomation::Element]
    #
    def main_web_view
      scroll_views[0].web_views[0]
    end
    
    # @!endgroup
    
    # @!group Element Collections
    
    # The window's tab bars
    has_element_array :tabBars, type: UIAutomation::TabBar
    
    # The window's navigation bars
    has_element_array :navigationBars, type: UIAutomation::NavigationBar
    
    # The window's toolbars
    has_element_array :toolbars
    
    # @!endgroup
    
    # @return [self] 
    def window
      self
    end
  end
end

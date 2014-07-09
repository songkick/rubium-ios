module UIAutomation
  # A RemoteProxy to UIAWindow objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIAWindowClassReference/
  #
  class Window < Element
    ### @!group Elements
    
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
    
    # @return [self] 
    def window
      self
    end
    
    ### @!endgroup
  end
end

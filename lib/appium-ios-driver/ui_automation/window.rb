require 'proxies/tab_bar'
require 'proxies/navigation_bar'

module UIAutomation
  class Window < UIAutomation::Element
    has_element :tabBar, type: UIAutomation::TabBar
    has_element :navigationBar, type: UIAutomation::NavigationBar
    has_element :toolbar
    has_element_array :tabBars, type: UIAutomation::TabBar
    has_element_array :navigationBars, type: UIAutomation::NavigationBar
    has_element_array :toolbars
    
    def main_table_view
      table_views[0]
    end
    
    def main_web_view
      scroll_views[0].web_views[0]
    end
    
    def window
      self
    end
  end
end

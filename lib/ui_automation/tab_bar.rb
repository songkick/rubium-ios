module UIAutomation
  class TabBar < UIAutomation::Element
    has_element :selectedButton
    
    alias :tabs :buttons
    
    def tap_tab(tab_name)
      tabs[tab_name].tap
    end
  end
end

module UIAutomation
  # A RemoteProxy to UIATableView objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIATableViewClassReference/
  #
  class TableView < Element
    ### @!group Element Collections

    # All of the cells in the table view
    has_element_array :cells
    
    # ALl of the visible cells in the table view
    has_element_array :visibleCells

    # All of the group elements in the table view
    has_element_array :groups

    ### @!endgroup
    
    ### @!group Actions

    # Scrolls down to the named cell until it is visible on screen.
    #
    # @param [String] name the name of the cell to scroll to
    def scroll_down_to_cell_named(name)
      cells[name].until_element(:visible?) { scroll_down }
    end
    
    # Scrolls up to the named cell until it is visible on screen.
    #
    # @param [String] name the name of the cell to scroll to
    def scroll_up_to_cell_named(name)
      cells[name].until_element(:visible?) { scroll_up }
    end

    ### @!endgroup
  end
end

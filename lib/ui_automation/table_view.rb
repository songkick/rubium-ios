module UIAutomation
  class TableView < UIAutomation::Element
    has_element_array :cells
    has_element_array :visibleCells

    def scroll_down_to_cell_named(name)
      cells[name].until_element(:visible?) { scroll_down }
    end
    
    def scroll_up_to_cell_named(name)
      cells[name].until_element(:visible?) { scroll_up }
    end
  end
end

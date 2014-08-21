module UIAutomation
  # Represents objects of type UIAElement in the Javascript API.
  #
  # UIAutomation::Element acts as the base class for all element types.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIAElementClassReference/
  class Element < RemoteProxy
    extend UIAutomation::ElementDefinitions

    # The proxy for the parent element
    # @note This returns the existing proxy that created this one; it does not use the UIAElement.parent() method
    # @return [UIAutomation::Element]
    attr_reader :parent

    # The window that contains this element
    # @return [UIAutomation::Window]
    attr_reader :window
    
    ### @!group Elements
    
    # The popover object associated with the current element
    has_element :popover, type: UIAutomation::Popover
    
    # The activity view associated with this element
    has_element :activityView, type: UIAutomation::ActivityView
    
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
    
    # @!endgroup

    ### @!group Element Collections

    # The element's parents
    has_element_array :ancestry

    # The element's children
    has_element_array :elements

    # All scroll views contained by this element
    has_element_array :scrollViews

    # All web views contained by this element
    has_element_array :webViews

    # All table views contained by this element
    has_element_array :tableViews, type: UIAutomation::TableView

    # All buttons contained by this element
    has_element_array :buttons

    # All static text elements contained by this element
    has_element_array :staticTexts

    # All text fields contained by this element
    has_element_array :textFields, type: UIAutomation::TextField

    # All secure text fields contained by this element
    has_element_array :secureTextFields, type: UIAutomation::TextField

    # All search bars contained by this element
    has_element_array :searchBars, type: UIAutomation::TextField

    # All segmented controls contained by this element
    has_element_array :segmentedControls

    # All switches contained by this element
    has_element_array :switches
    
    # All images contained by this element
    has_element_array :images
    
    # All links contained by this element
    has_element_array :links
    
    # All page indicators contained by this element
    has_element_array :pageIndicators
    
    # All pickers contained by this element
    has_element_array :pickers, type: UIAutomation::Picker
    
    # All progress indicators contained by this element
    has_element_array :progressIndicators
    
    # All sliders contained by this element
    has_element_array :sliders
    
    # All text views contained by this element
    has_element_array :textViews, type: UIAutomation::TextView
    
    # All collection views contained by this element
    has_element_array :collectionViews
    
    # All actvity indicators associated with this element
    has_element_array :activityIndicators
    
    # The window's tab bars
    has_element_array :tabBars, type: UIAutomation::TabBar
    
    # The window's navigation bars
    has_element_array :navigationBars, type: UIAutomation::NavigationBar
    
    # The window's toolbars
    has_element_array :toolbars

    ### @!endgroup

    # Initializes a new element.
    # As well as the parameters of its super-class, it also takes a parent element and window proxy.
    # @api private
    #
    def initialize(executor, remote_object, parent_element, window = nil)
      super executor, remote_object
      @parent = parent_element
      @window = window
    end

    ### @!group Checking Element State

    # Returns true if the element is valid.
    # This uses the UIAElement method checkIsValid() to ensure that the most up-to-date status is returned.
    # @return [Boolean]
    #
    def valid?
      perform :checkIsValid
    end

    # Indicates if the element is currently visible.
    # @return [Boolean]
    # @see UIAElement.isVisible()
    def visible?
      perform(:isVisible) == 1
    end

    # Indicates if the element is currently enabled.
    # @return [Boolean]
    # @see UIAElement.isEnabled()
    #
    def enabled?
      perform(:isEnabled) == 1
    end

    # Indicates if the element is currently selected.
    # @return [Boolean]
    # @see UIAElement.isSelected()
    #
    def selected?
      perform(:isSelected)
    end

    # Indicates if the element has keyboard focus.
    # @return [Boolean]
    # @see UIAElement.hasKeyboardFocus()
    #
    def has_keyboard_focus?
      perform(:hasKeyboardFocus) == 1
    end
    
    # Calls the given block when the element becomes valid. If the element is already valid
    # the block is called immediately.
    # @yieldparam [self] element
    #
    def when_valid(&block)
      when_element_is(:valid?, &block)
    end

    # Calls the given block when the element passes one ore more predicates.
    #
    # Each predicate method specified will be called and if they all return true, the given block will be called,
    # otherwise it will wait for all predicates to return true.
    #
    # @param [List<Symbol>] predicates One or more symbols representing boolean methods defined on the current class.
    # @yieldparam [self] element
    # @raise [Rubium::Driver::TimeoutError] if all predicates do not return true within the default timeout.
    #
    # @example Tap the element once it is selected and has keyboard focus
    #     element.when_element(:selected?, :has_keyboard_focus?) { |el| el.tap }
    #
    def when_element(*predicates, &block)
      executor.wait_until do
        predicates.all? { |p| __send__(p) }
      end

      yield self if block_given?
    end
    alias :when_element_is :when_element

    # Repeatedly calls the given block until the element passes one ore more predicates.
    #
    # Each predicate method specified will be called and if they all return true, the given block will never be called,
    # otherwise, the block will be called continuously with a small delay between each call until they do. 
    #
    # The predicates will be checked before each block call.
    #
    # @param [List<Symbol>] predicates One or more symbols representing boolean methods defined on the current class.
    # @yieldparam [self] element
    # @raise [Rubium::Driver::TimeoutError] if all predicates do not return true within the default timeout.
    #
    # @example Scroll the table view until a specific cell is visible
    #     expected_cell = table_view.cells['Some Name']
    #     expected_cell.until_element(:visible?) { table_view.scroll_down }
    #
    def until_element(*predicates, &block)
      executor.wait_until do
        if predicates.all? { |p| __send__(p) }
          true
        else
          yield self if block_given?
        end
      end
    end
    
    ### @!endgroup
    
    ### @!group Gestures and Actions

    # Perform a single tap on the element.
    # This method waits for the element to become valid and visible before performing the tap.
    # To perform a tap immediately without waiting, use #tap!
    # @see #tap!
    #
    def tap # define this explicitly due to conflict with Object#tap
      when_element_is(:valid?, :visible?, :enabled?) { tap! }
    end

    # Performs a single tap on the element without waiting.
    # Use this method when you are certain that an element is both valid and visible - calling this
    # may result in an error if the element is not tappable.
    #
    def tap!
      perform(:tap)
    end

    ### @!endgroup

    def application
      window.parent
    end
  end
end

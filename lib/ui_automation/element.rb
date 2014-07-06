require 'wrong'

module UIAutomation
  # Represents objects of type UIAElement in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIAElementClassReference/UIAElement/UIAElement.html#//apple_ref/doc/uid/TP40009903 Apple UIAElement Documentation
  class Element < RemoteProxy
    extend UIAutomation::ElementDefinitions

    include Wrong::Assert
    include Wrong::Eventually

    # The proxy for the parent element
    # @note This returns the existing proxy that created this one; it does not use the UIAElement.parent() method
    # @return [UIAutomation::Element]
    attr_reader :parent

    # The window that contains this element
    # @return [UIAutomation::Window]
    attr_reader :window

    # @!group Element Collections

    # The element's parents
    has_element_array :ancestry

    # The element's children
    has_element_array :elements

    # All scroll views contained by this element
    has_element_array :scrollViews

    # All web views contained by this element
    has_element_array :webViews

    # All table views contained by this element
    has_element_array :tableViews,       type: UIAutomation::TableView

    # All buttons contained by this element
    has_element_array :buttons

    # All static text elements contained by this element
    has_element_array :staticTexts

    # All text fields contained by this element
    has_element_array :textFields,       type: UIAutomation::TextField

    # All secure text fields contained by this element
    has_element_array :secureTextFields, type: UIAutomation::TextField

    # All search bars contained by this element
    has_element_array :searchBars,       type: UIAutomation::TextField

    # All segmented controls contained by this element
    has_element_array :segmentedControls

    # All switches contained by this element
    has_element_array :switches

    # @!endgroup

    # Initializes a new element.
    # As well as the parameters of its super-class, it also takes a parent element and window proxy.
    # @api private
    #
    def initialize(driver, remote_object, parent_element, window = nil)
      super driver, remote_object
      @parent = parent_element
      @window = window
    end

    # @!group Checking Element State

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
    # @raises [Wrong::Assert::AssertionFailedError] if all predicates do not return true within the default timeout.
    #
    # @example Tap the element once it is selected and has keyboard focus
    #     element.when_element(:selected?, :has_keyboard_focus?) { |el| el.tap }
    #
    def when_element(*predicates, &block)
      eventually do
        predicates.all? { |p| __send__(p) }
      end

      yield self if block_given?

    rescue Wrong::Assert::AssertionFailedError => e
      raise Wrong::Assert::AssertionFailedError.new("Expect #{self} #{predicates.join(", ")}")
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
    # @raises [Wrong::Assert::AssertionFailedError] if all predicates do not return true within the default timeout.
    #
    # @example Scroll the table view until a specific cell is visible
    #     expected_cell = table_view.cells['Some Name']
    #     expected_cell.until_element(:visible?) { table_view.scroll_down }
    #
    def until_element(*predicates, &block)
      eventually do
        if predicates.all? { |p| __send__(p) }
          true
        else
          yield self if block_given?
        end
      end
    end
    
    # @!endgroup
    
    # @!group Gestures and Actions

    # Perform a single tap on the element.
    # This method waits for the element to become valid and visible before performing the tap.
    # To perform a tap immediately without waiting, use #tap!
    # @see #tap!
    #
    def tap # define this explicitly due to conflict with Object#tap
      when_element_is(:valid?, :visible?) { tap! }
    end

    # Performs a single tap on the element without waiting.
    # Use this method when you are certain that an element is both valid and visible - calling this
    # may result in an error if the element is not tappable.
    #
    def tap!
      perform(:tap)
    end

    # @!endgroup

    def application
      window.parent
    end
  end
end

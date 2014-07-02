require 'proxies/text_field'
require 'proxies/table_view'
require 'wrong'

module UIAutomation
  class Element < RemoteProxy
    include Wrong::Assert
    include Wrong::Eventually
    
    attr_reader :parent, :window
    
    has_element_array :ancestry
    has_element_array :elements
    has_element_array :scrollViews
    has_element_array :webViews
    has_element_array :tableViews,       type: UIAutomation::TableView
    has_element_array :buttons
    has_element_array :staticTexts
    has_element_array :textFields,       type: UIAutomation::TextField
    has_element_array :secureTextFields, type: UIAutomation::TextField
    has_element_array :searchBars,       type: UIAutomation::TextField
    has_element_array :segmentedControls
    has_element_array :switches
    
    def initialize(driver, remote_object, parent_element, window = nil)
      super driver, remote_object
      @parent = parent_element
      @window = window
    end

    def valid?
      perform :checkIsValid
    end

    def visible?
      perform(:isVisible) == 1
    end

    def enabled?
      perform(:isEnabled) == 1
    end
    
    def selected?
      perform(:isSelected)
    end

    def has_keyboard_focus?
      perform(:hasKeyboardFocus) == 1
    end

    def tap # define this explicitly due to conflict with Object#tap
      when_element_is(:valid?, :visible?) { tap! }
    end
    
    def tap!
      perform(:tap)
    end
    
    def when_valid(&block)
      when_element_is(:valid?, &block)
    end
    
    def when_element(*predicates, &block)
      eventually do
        predicates.all? { |p| __send__(p) }
      end
      
      yield self if block_given?
      
    rescue Wrong::Assert::AssertionFailedError => e
      raise Wrong::Assert::AssertionFailedError.new("Expect #{self} #{predicates.join(", ")}")
    end
    alias :when_element_is :when_element
    
    def until_element(*predicates, &block)
      eventually do
        if predicates.all? { |p| __send__(p) }
          true
        else
          yield self if block_given?
        end
      end
    end
    
    def application
      window.parent
    end
  end
end

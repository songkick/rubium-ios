module UIAutomation
  # A RemoteProxy to UIATextField objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIATextFieldClassReference/
  #
  class TextField < UIAutomation::Element
    ### @!group Actions    
    
    # Sets the text of the text field directly, bypassing the keyboard.
    #
    # If the text field does not currently have keyboard focus, it will be tapped first.
    #
    # @param [String] value the text to use as the text field's new value
    #
    def text=(value)
      with_keyboard_focus do
        perform :setValue, value
      end
    end
    
    # Begins typing in the text field using the on-screen keyboard
    #
    # If the text field has keyboard focus and the keyboard is visible, then the given 
    # block will be called immediately.
    #
    # Otherwise, this method will tap the text field if necessary, wait until it reports that
    # it has keyboard focus, wait for the keyboard to become visible if it isn't
    # already and then call the block.
    #
    # As a convenience, a proxy to the keyboard is yielded to the block.
    #
    # This method does not dismiss the keyboard automatically.
    #
    # @example Simulate typing in a text field using the on-screen keyboard
    #     text_field.begin_typing do |keyboard|
    #       keyboard.type "some text"
    #     end
    #
    # @yieldparam [UIAutomation::Keyboard] keyboard the keyboard proxy
    #
    def begin_typing(&block)
      with_keyboard_focus do
        application.keyboard.when_element(:visible?) do
          yield application.keyboard if block_given?
        end
      end
    end
    
    ### @!endgroup
    
    private
    
    def with_keyboard_focus(&block)
      tap unless has_keyboard_focus?
      when_element(:has_keyboard_focus?, &block)
    end
  end
end

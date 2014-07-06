module UIAutomation
  # A RemoteProxy to UIATextField objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIATextFieldClassReference/
  #
  class TextField < UIAutomation::Element
    def text=(value)
      tap unless has_keyboard_focus?
      perform :setValue, value
    end
    
    def begin_typing(&block)
      tap unless has_keyboard_focus?
      when_element(:has_keyboard_focus?) do
        application.keyboard.when_element(:visible?) do
          yield application.keyboard if block_given?
        end
      end
    end
  end
end

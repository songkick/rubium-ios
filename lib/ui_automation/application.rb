module UIAutomation
  # A RemoteProxy to UIAApplication objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIAApplicationClassReference/
  #
  class Application < RemoteProxy
    extend ElementDefinitions
    
    # @!group Elements

    # The application's main window.
    has_element :mainWindow, type: UIAutomation::Window
    
    # The currently active action sheet.
    has_element :actionSheet
    
    # The system keyboard.
    has_element :keyboard, type: UIAutomation::Keyboard
    
    # @!endgroup
    
    # @!group Element Collections
    
    # The application's windows.
    has_element_array :windows, type: UIAutomation::Window

    # @!endgroup
    
  end
end

module UIAutomation
  class Application < RemoteProxy
    extend ElementDefinitions
    
    has_element :mainWindow, type: UIAutomation::Window
    has_element :actionSheet
    has_element :keyboard, type: UIAutomation::Keyboard
    has_element_array :windows, type: UIAutomation::Window
  end
end

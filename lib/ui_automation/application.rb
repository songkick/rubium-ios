module UIAutomation
  # A RemoteProxy to UIAApplication objects in the Javascript API.
  #
  # @see https://developer.apple.com/library/ios/documentation/ToolsLanguages/Reference/UIAApplicationClassReference/
  #
  class Application < RemoteProxy
    extend ElementDefinitions
    
    ### @!group Elements

    # The application's main window.
    has_element :mainWindow, type: UIAutomation::Window
    
    # The currently active action sheet.
    has_element :actionSheet, type: UIAutomation::ActionSheet
    
    # The system keyboard.
    has_element :keyboard, type: UIAutomation::Keyboard
    
    # The currently displayed alert view
    has_element :alert, type: UIAutomation::Alert
    
    # The currently displayed editing menu
    has_element :editingMenu
    
    # The application's tab bar.
    #
    # On an iPhone there will normally only be one tab bar but an iPad may have multiple.
    has_element :tabBar, type: UIAutomation::TabBar
    
    # The application's navigation bar.
    #
    # On an iPhone there will normally only be one navigation bar but an iPad may have multiple.
    has_element :navigationBar, type: UIAutomation::NavigationBar
    
    # The application's toolbar.
    # 
    # On an iPhone there will normally only be one toolbar but an iPad may have multiple.
    has_element :toolbar
    
    # The application status bar
    has_element :statusBar
    
    ### @!endgroup
    
    ### @!group Element Collections
    
    # The application's windows.
    has_element_array :windows, type: UIAutomation::Window

    ### @!endgroup
    
    def bundle_id
      perform :bundleID
    end    
  end
end

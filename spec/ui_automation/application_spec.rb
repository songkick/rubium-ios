require 'spec_helper'

describe UIAutomation::Application do
  subject { UIAutomation::Application.new(double, '<application>') }
  
  it { should have_proxy(:main_window).to_element('.mainWindow()').of_type(UIAutomation::Window) }
  it { should have_proxy(:action_sheet).to_element(".actionSheet()").of_type(UIAutomation::ActionSheet) }
  it { should have_proxy(:keyboard).to_element.of_type(UIAutomation::Keyboard)}
  it { should have_proxy(:windows).to_element_array.of_type(UIAutomation::Window) }
  it { should have_proxy(:alert).to_element.of_type(UIAutomation::Alert) }
  it { should have_proxy(:editing_menu).to_element('.editingMenu()') }
  it { should have_proxy(:tab_bar).to_element('.tabBar()').of_type(UIAutomation::TabBar) }
  it { should have_proxy(:navigation_bar).to_element('.navigationBar()').of_type(UIAutomation::NavigationBar) }
  it { should have_proxy(:toolbar).to_element }
  it { should have_proxy(:status_bar).to_element('.statusBar()') }
end

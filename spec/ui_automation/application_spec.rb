require 'spec_helper'

describe UIAutomation::Application do
  subject { UIAutomation::Application.new(double, '<application>') }
  
  it { should have_proxy(:main_window).to_element(".mainWindow()").of_type(UIAutomation::Window) }
  it { should have_proxy(:action_sheet).to_element(".actionSheet()") }
  it { should have_proxy(:keyboard).to_element(".keyboard()") .of_type(UIAutomation::Keyboard)}
  it { should have_proxy(:windows).to_element_array(".windows()").of_type(UIAutomation::Window) }
end

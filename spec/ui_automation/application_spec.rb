require 'spec_helper'

describe UIAutomation::Application do
  subject { UIAutomation::Application.new(double, 'SomeClass.application()') }
  
  it { is_expected.to have_element_proxy(:mainWindow).of_type(UIAutomation::Window) }
  it { is_expected.to have_element_proxy(:actionSheet) }
  it { is_expected.to have_element_proxy(:keyboard).of_type(UIAutomation::Keyboard) }
  it { is_expected.to have_element_array_proxy(:windows).of_type(UIAutomation::Window) }
end

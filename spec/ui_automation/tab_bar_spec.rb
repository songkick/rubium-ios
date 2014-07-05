require 'spec_helper'

describe UIAutomation::TabBar do
  subject { UIAutomation::TabBar.new(double, '<tabbar>', double, double) }
  
  it { should have_proxy(:selected_button).to_element('.selectedButton()') }
  it { should have_proxy(:tabs).to_element_array('.buttons()') }
end

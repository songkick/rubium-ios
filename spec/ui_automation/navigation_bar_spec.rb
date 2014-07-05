require 'spec_helper'

describe UIAutomation::NavigationBar do
  subject { UIAutomation::NavigationBar.new(double, '<navbar>', double, double) }
  
  it { should have_proxy(:left_button).to_element('.leftButton()') }
  it { should have_proxy(:right_button).to_element(".rightButton()") }
end

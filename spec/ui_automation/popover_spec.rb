require 'spec_helper'

describe UIAutomation::Popover do
  subject { UIAutomation::Popover.new(double, '<popover>', double, double) }
  
  it { should have_proxy(:action_sheet).to_element(".actionSheet()").of_type(UIAutomation::ActionSheet) }
  it { should have_proxy(:navigation_bar).to_element(".navigationBar()").of_type(UIAutomation::NavigationBar) }
  it { should have_proxy(:tab_bar).to_element(".tabBar()").of_type(UIAutomation::TabBar) }
  it { should have_proxy(:toolbar).to_element }
end

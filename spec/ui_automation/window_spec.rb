require 'spec_helper'

describe UIAutomation::Window do
  subject { UIAutomation::Window.new(double, '<window>', double, double) }
  
  it { should have_proxy(:tab_bar).to_element('.tabBar()').of_type(UIAutomation::TabBar) }
  it { should have_proxy(:navigation_bar).to_element('.navigationBar()').of_type(UIAutomation::NavigationBar) }
  it { should have_proxy(:toolbar).to_element }
  it { should have_proxy(:tab_bars).to_element_array('.tabBars()').of_type(UIAutomation::TabBar) }
  it { should have_proxy(:navigation_bars).to_element_array('.navigationBars()').of_type(UIAutomation::NavigationBar) }
  it { should have_proxy(:toolbars).to_element_array }
  it { should have_proxy(:main_table_view).to_element('.tableViews()[0]') }
  it { should have_proxy(:main_web_view).to_element('.scrollViews()[0].webViews()[0]') }
end

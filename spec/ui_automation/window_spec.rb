require 'spec_helper'

describe UIAutomation::Window do
  subject { UIAutomation::Window.new(double, '<window>', double, double) }
  
  it { should have_proxy(:main_table_view).to_element('.tableViews()[0]') }
  it { should have_proxy(:main_web_view).to_element('.scrollViews()[0].webViews()[0]') }
end

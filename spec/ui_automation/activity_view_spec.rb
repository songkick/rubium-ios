require 'spec_helper'

describe UIAutomation::ActivityView do
  subject { UIAutomation::ActivityView.new(double, '<view>', double, double) }
  
  it { should have_proxy(:cancel_button).to_element('.cancelButton()') }
end

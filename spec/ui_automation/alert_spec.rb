require 'spec_helper'

describe UIAutomation::Alert do
  subject { UIAutomation::Alert.new(double, '<alert>', double, double) }
  
  it { should have_proxy(:cancel_button).to_element(".cancelButton()") }
  it { should have_proxy(:default_button).to_element(".defaultButton()") }
end

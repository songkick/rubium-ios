require 'spec_helper'

describe UIAutomation::ActionSheet do
  subject { UIAutomation::ActionSheet.new(double, '<sheet>', double, double) }
  
  it { should have_proxy(:cancel_button).to_element(".cancelButton()") }
end

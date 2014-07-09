require 'spec_helper'

describe UIAutomation::Picker do
  subject { UIAutomation::Picker.new(double, '<picker>', double, double) }
  
  it { should have_proxy(:wheels).to_element_array }
end

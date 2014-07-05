require 'spec_helper'

describe UIAutomation::TableView do
  subject { UIAutomation::TableView.new(double, '<tableview>', double, double) }
  
  it { should have_proxy(:cells).to_element_array }
  it { should have_proxy(:visible_cells).to_element_array('.visibleCells()') }
end

require 'spec_helper'

describe UIAutomation::Keyboard do
  let(:executor) { double }
  
  subject { UIAutomation::Keyboard.new(executor, '<keyboard>', double, double) }
  
  it { should have_proxy(:keys).to_element_array('.keys()') }
  it { should have_proxy(:done_button).to_element('.buttons().firstWithName(\'Done\')') }
  it { should have_proxy(:return_button).to_element('.buttons().firstWithName(\'Return\')') }
  
  it "can type a given string" do
    expect(executor).to receive(:execute_script).with("#{subject}.typeString('test')")
    subject.type('test')
  end
end

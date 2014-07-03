require 'spec_helper'

describe UIAutomation::Target, '.local_target' do
  let(:executor) { double }
  
  subject { UIAutomation::Target.local_target(executor) }
  
  it "returns a proxy to UIATarget.localTarget()" do
    expect(subject.to_javascript).to eql("UIATarget.localTarget()")
  end
  
  it "returns an Application proxy for the front-most app" do
    expected = 'UIATarget.localTarget().frontMostApp()'
    expect(subject.front_most_app).to be_remote_proxy_to(expected).of_type(UIAutomation::Application)
  end
  
  it "can perform a tap on an element using its rect" do
    rect = {x: 0, y: 0, width: 100, height: 100}
    element = double(rect: rect)
    expected = "#{subject.javascript}.tap(#{rect.to_json})"
    expect(executor).to receive(:execute_script).with(expected)
    subject.tap_element(element)
  end
  
  it "can call setLocation() using a hash as input" do
    location = {lat: 90, lng: 90}
    expected = "#{subject.javascript}.setLocation(#{location.to_json})"
    expect(executor).to receive(:execute_script).with(expected)
    subject.location = location
  end
end

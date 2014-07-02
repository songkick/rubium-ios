require 'spec_helper'

describe UIAutomation::RemoteProxy, "(element proxy extensions)" do
  let(:driver) { double }

  subject { UIAutomation::RemoteProxy.from_javascript(driver, 'SomeClass.someObject()') }
  
  it "can return a remote element proxy" do
    proxy = subject.element_proxy_for(:someElement)
    expect(proxy).to be_remote_proxy_to('SomeClass.someObject().someElement()').of_type(UIAutomation::Element)
  end
  
  it "can return a remote element proxy with a custom type" do
    proxy = subject.element_proxy_for(:someElement, UIAutomation::TextField)
    expect(proxy).to be_remote_proxy_to('SomeClass.someObject().someElement()').of_type(UIAutomation::TextField)
  end
  
  it "raises if the remote element type is not a sub-class of UIAutomation::Element" do
    expect { subject.element_proxy_for(:someElement, Object) }.to raise_error(TypeError)
  end
  
  it "supports [] syntax as a way of getting an element proxy" do
    proxy = subject[:someElement]
    expect(proxy).to be_remote_proxy_to('SomeClass.someObject().someElement()').of_type(UIAutomation::Element)
  end
  
  it "can return an element array proxy of UIAutomation::Element types" do
    proxy = subject.element_array_proxy_for(:someElements)
    expect(proxy).to be_remote_proxy_to('SomeClass.someObject().someElements()').of_type(UIAutomation::ElementArray)
    expect(proxy.element_klass).to eql(UIAutomation::Element)
  end
  
  it "can return an element array proxy of custom element types" do
    proxy = subject.element_array_proxy_for(:someElements, UIAutomation::TextField)
    expect(proxy).to be_remote_proxy_to('SomeClass.someObject().someElements()').of_type(UIAutomation::ElementArray)
    expect(proxy.element_klass).to eql(UIAutomation::TextField)
  end
  
  describe "an element proxy" do
    let(:window) { double }
    let(:element_proxy) { subject.element_proxy_for(:someElement) }
    
    before do
      allow(subject).to receive(:window).and_return(window)
    end
    
    it "uses the same driver as the parent proxy" do
      expect(driver).to receive(:execute_script).with(element_proxy.javascript)
      element_proxy.execute_self
    end
    
    it "has a reference to the parent that created the proxy" do
      expect(element_proxy.parent).to eql(subject)
    end
    
    it "has a reference to the parent's window" do
      expect(element_proxy.window).to eql(window)
    end
  end
  
  describe "an element array proxy" do
    let(:window) { double }
    let(:element_array_proxy) { subject.element_array_proxy_for(:someElements) }
    
    before do
      allow(subject).to receive(:window).and_return(window)
    end
    
    it "uses the same driver as the parent proxy" do
      expect(driver).to receive(:execute_script).with(element_array_proxy.javascript)
      element_array_proxy.execute_self
    end
    
    it "has a reference to the parent that created the proxy" do
      expect(element_array_proxy.parent).to eql(subject)
    end
    
    it "has a reference to the parent's window" do
      expect(element_array_proxy.window).to eql(window)
    end
  end
end

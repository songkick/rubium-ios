require 'spec_helper'

describe UIAutomation::ElementArray do
  let(:executor) { double }
  let(:parent) { double }
  let(:window) { double }

  subject { UIAutomation::ElementArray.new(executor, 'SomeClass.someArray()', UIAutomation::Element, parent, window) }
  
  it "returns element proxies of type UIAutomation::Element by default" do
    expect(subject.element_klass).to eql(UIAutomation::Element)
  end
  
  it "returns the number of elements in the array" do
    allow(executor).to receive(:execute_script).with('SomeClass.someArray().length').and_return(3)
    expect(subject.length).to eql(3)
  end
  
  describe "#at_index" do
    let(:proxy) { subject.at_index(1) }
    
    it "returns an element proxy for the element returned by UIAElement.[<int>]" do
      expect(proxy).to be_remote_proxy_to('SomeClass.someArray()[1]').of_type(subject.element_klass)
    end
    
    it "can also be called using [] syntax with an integer argument" do
      other_proxy = subject[1]
      expect(other_proxy).to be_remote_proxy_to(proxy.to_javascript)
    end
  end
  
  describe "#first_with_name" do
    let(:proxy) { subject.first_with_name('test') }
    
    it "returns an element proxy for the element returned by UIAElement.firstWithName(<name>)" do
      expected = 'SomeClass.someArray().firstWithName(\'test\')'
      expect(proxy).to be_remote_proxy_to(expected).of_type an_instance_of(UIAutomation::Element)
    end

    it "can also be called using [] syntax with a string argument" do
      other_proxy = subject['test']
      expect(other_proxy).to be_remote_proxy_to(proxy.to_javascript)
    end
  end
  
  describe "#first_with_predicate" do
    let(:proxy) { subject.first_with_predicate('test like :value', value: 123) }
    
    it "returns an element proxy for the element returned by UIAElement.firstWithPredicate(<predicate>)" do
      expected = 'SomeClass.someArray().firstWithPredicate(\'test like 123\')'
      expect(proxy).to be_remote_proxy_to(expected).of_type(subject.element_klass)
    end
  end
  
  shared_examples_for "an ElementArray proxy method" do
    it "returns an ElementArray whose element type matches the same as its own type" do
      expect(proxy.element_klass).to eql(subject.element_klass)
    end
    
    it "returns an ElementArray with the same parent as itself" do
      expect(proxy.parent).to eql(subject.parent)
    end
    
    it "returns an ElementArray with the same window as itself" do
      expect(proxy.window).to eql(subject.window)
    end
  end
  
  describe "#with_name" do
    let(:proxy) { subject.with_name('test') }
    
    it "returns an ElementArray proxy to the element array returned by UIAElement.withName(<name>)" do
      expected = 'SomeClass.someArray().withName(\'test\')'
      expect(proxy).to be_remote_proxy_to(expected).of_type(UIAutomation::ElementArray)
    end
    
    it_behaves_like "an ElementArray proxy method"
  end
  
  describe "#with_predicate" do
    let(:proxy) { subject.with_predicate('test like :value', value: 123) }
    
    it "returns an ElementArray proxy to the element array returned by UIAElement.withPredicate(<predicate>)" do
      expected = 'SomeClass.someArray().withPredicate(\'test like 123\')'
      expect(proxy).to be_remote_proxy_to(expected).of_type(UIAutomation::ElementArray)
    end
    
    it_behaves_like "an ElementArray proxy method"
  end
  
  describe "#with_value_for_key" do
    let(:proxy) { subject.with_value_for_key('test-key', 'test-value') }
    
    it "returns an ElementArray proxy to the element array returned by UIAElement.withValueForKey(<value>, <key>)" do
      expected = 'SomeClass.someArray().withValueForKey(\'test-value\', \'test-key\')'
      expect(proxy).to be_remote_proxy_to(expected).of_type(UIAutomation::ElementArray)
    end
    
    it_behaves_like "an ElementArray proxy method"
  end
  
  it "provides a convenience method for fetching elements by their value" do
    expected = 'SomeClass.someArray().withValueForKey(\'test-value\', \'value\')'
    proxy = subject.with_value('test-value')
    expect(proxy).to be_remote_proxy_to(expected).of_type(UIAutomation::ElementArray)
  end
  
  describe "#first_with_value" do
    it "returns an element proxy to the first element if at least one" do
      length_js = 'SomeClass.someArray().withValueForKey(\'test-value\', \'value\').length'
      allow(executor).to receive(:execute_script).with(length_js).and_return(3)
      expected = 'SomeClass.someArray().withValueForKey(\'test-value\', \'value\')[0]'
      proxy = subject.first_with_value('test-value')
      expect(proxy).to be_remote_proxy_to(expected).of_type(UIAutomation::Element)
    end
    
    it "returns nil if no elements exist with the given value" do
      length_js = 'SomeClass.someArray().withValueForKey(\'test-value\', \'value\').length'
      allow(executor).to receive(:execute_script).with(length_js).and_return(0)
      proxy = subject.first_with_value('test-value')
      expect(proxy).to be_nil
    end
  end
  
  context "enumeration" do
    it "can be enumerated over using #each" do
      allow(executor).to receive(:execute_script).with('SomeClass.someArray().length').and_return(3)

      proxies = []
      subject.each { |proxy| proxies << proxy }

      expect(proxies).to contain_exactly(
        remote_proxy_to('SomeClass.someArray()[0]').of_type(subject.element_klass),
        remote_proxy_to('SomeClass.someArray()[1]').of_type(subject.element_klass),
        remote_proxy_to('SomeClass.someArray()[2]').of_type(subject.element_klass)
      )
    end

    it "returns an enumerator when calling #each without a block" do
      allow(executor).to receive(:execute_script).with('SomeClass.someArray().length').and_return(3)

      expect(subject.each.to_a).to contain_exactly(
        remote_proxy_to('SomeClass.someArray()[0]').of_type(subject.element_klass),
        remote_proxy_to('SomeClass.someArray()[1]').of_type(subject.element_klass),
        remote_proxy_to('SomeClass.someArray()[2]').of_type(subject.element_klass)
      )
    end

    it "supports Enumerable (using #map as an example)" do
      allow(executor).to receive(:execute_script).with('SomeClass.someArray().length').and_return(3)

      expect(subject.map(&:to_javascript)).to include(
        'SomeClass.someArray()[0]',
        'SomeClass.someArray()[1]',
        'SomeClass.someArray()[2]'
      )
    end
  end
end

describe UIAutomation::PredicateString do
  it "can be constructed with a simple string" do
    predicate = UIAutomation::PredicateString.new("age = 10")
    expect(predicate.to_s).to eql("age = 10")
  end
  
  it "can be constructed with template substitutions" do
    predicate = UIAutomation::PredicateString.new("age = :age", age: 10)
    expect(predicate.to_s).to eql("age = 10")
  end
  
  it "correctly quotes strings with escaped quotes" do
    predicate = UIAutomation::PredicateString.new("name = :name", name: "Joe")
    expect(predicate.to_s).to eql("name = \"Joe\"")
  end
  
  it "supports multiple substitutions" do
    predicate = UIAutomation::PredicateString.new("age = :age AND year = :year", age: 10, year: 2014)
    expect(predicate.to_s).to eql("age = 10 AND year = 2014")
  end
end

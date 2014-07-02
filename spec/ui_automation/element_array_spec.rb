require 'spec_helper'

describe UIAutomation::ElementArray do
  let(:driver) { double }

  subject { UIAutomation::ElementArray.new(driver, 'SomeClass.someArray()') }
  
  it "returns element proxies of type UIAutomation::Element by default" do
    expect(subject.element_klass).to eql(UIAutomation::Element)
  end
  
  it "returns the number of elements in the array" do
    allow(driver).to receive(:execute_script).with('SomeClass.someArray().length').and_return(3)
    expect(subject.length).to eql(3)
  end
  
  it "returns an element proxy for an element at a specific index" do
    proxy = subject.at_index(1)
    expect(proxy).to be_remote_proxy_to('SomeClass.someArray()[1]').of_type(subject.element_klass)
  end
  
  it "supports [] syntax for fetching elements by index" do
    proxy = subject[1]
    expect(proxy).to be_remote_proxy_to('SomeClass.someArray()[1]').of_type(subject.element_klass)
  end
  
  it "returns an element proxy for the first element with a given name" do
    proxy = subject.first_with_name('test')
    expect(proxy).to be_remote_proxy_to('SomeClass.someArray().firstWithName(\'test\')').of_type(subject.element_klass)
  end
  
  it "supports [] syntax for fetching elements by name" do
    proxy = subject['test']
    expect(proxy).to be_remote_proxy_to('SomeClass.someArray().firstWithName(\'test\')').of_type(subject.element_klass)
  end
  
  it "returns an element proxy for the first element matching a predicate" do
    proxy = subject.first_with_predicate('test like :value', value: 123)
    expected = 'SomeClass.someArray().firstWithPredicate(\'test like 123\')'
    expect(proxy).to be_remote_proxy_to(expected).of_type(subject.element_klass)
  end
  
  it "can be enumerated over using #each" do
    allow(driver).to receive(:execute_script).with('SomeClass.someArray().length').and_return(3)
    
    proxies = []
    subject.each { |proxy| proxies << proxy }

    expect(proxies).to contain_exactly(
      remote_proxy_to('SomeClass.someArray()[0]').of_type(subject.element_klass),
      remote_proxy_to('SomeClass.someArray()[1]').of_type(subject.element_klass),
      remote_proxy_to('SomeClass.someArray()[2]').of_type(subject.element_klass)
    )
  end
  
  it "returns an enumerator when calling #each without a block" do
    allow(driver).to receive(:execute_script).with('SomeClass.someArray().length').and_return(3)

    expect(subject.each.to_a).to contain_exactly(
      remote_proxy_to('SomeClass.someArray()[0]').of_type(subject.element_klass),
      remote_proxy_to('SomeClass.someArray()[1]').of_type(subject.element_klass),
      remote_proxy_to('SomeClass.someArray()[2]').of_type(subject.element_klass)
    )
  end
  
  it "supports Enumerable (using #map as an example)" do
    allow(driver).to receive(:execute_script).with('SomeClass.someArray().length').and_return(3)

    expect(subject.map(&:to_javascript)).to include(
      'SomeClass.someArray()[0]',
      'SomeClass.someArray()[1]',
      'SomeClass.someArray()[2]'
    )
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

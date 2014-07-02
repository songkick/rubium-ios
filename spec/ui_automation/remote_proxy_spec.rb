require 'spec_helper'

describe UIAutomation::RemoteProxy do
  let(:driver) { double }

  subject { UIAutomation::RemoteProxy.from_javascript(driver, 'SomeClass.someObject()') }
  
  it "can return its Javascript value" do
    expect(subject.to_javascript).to eql('SomeClass.someObject()')
  end
  
  it "can execute itself" do
    expect(driver).to receive(:execute_script).with('SomeClass.someObject()')
    subject.execute_self
  end
  
  it "can fetch a property on the remote object" do
    expect(driver).to receive(:execute_script).with('SomeClass.someObject().someProperty').and_return('value')
    expect(subject.fetch(:someProperty)).to eql('value')
  end
  
  it "can perform a function on the remote object without arguments" do
    expect(driver).to receive(:execute_script).with('SomeClass.someObject().someFunction()')
    subject.perform(:someFunction)
  end
  
  it "can perform a function on the remote object with numeric arguments" do
    expect(driver).to receive(:execute_script).with('SomeClass.someObject().someFunction(1, 2, 3)')
    subject.perform(:someFunction, 1, 2, 3)
  end
  
  it "can perform a function on the remote object with string or symbol arguments" do
    expect(driver).to receive(:execute_script).with('SomeClass.someObject().someFunction(\'arg1\', \'arg2\')')
    subject.perform(:someFunction, 'arg1', :arg2)
  end
  
  it "can perform a function on the remote object with an array argument" do
    expect(driver).to receive(:execute_script).with('SomeClass.someObject().someFunction([1,2,"three"])')
    subject.perform(:someFunction, [1, 2, "three"])
  end
  
  it "can perform a function on the remote object with a hash argument" do
    expect(driver).to receive(:execute_script).with('SomeClass.someObject().someFunction({"foo":"bar"})')
    subject.perform(:someFunction, {foo: 'bar'})
  end
  
  it "can perform a function on a remote object by calling the method directly on the proxy" do
    expect(driver).to receive(:execute_script).with('SomeClass.someObject().someFunction()')
    subject.someFunction
  end
  
  it "can perform a function on a remote object with arguments by calling the method directly on the proxy" do
    expect(driver).to receive(:execute_script).with('SomeClass.someObject().someFunction(1, 2, 3)')
    subject.someFunction(1, 2, 3)
  end
  
  it "can perform functions invoked using snake_case as lowerCamelCase" do
    expect(driver).to receive(:execute_script).with('SomeClass.someObject().someFunction()')
    subject.some_function
  end
  
  it "can return a new proxy for an object returned by a specified function" do
    proxy = subject.proxy_for(:someFunction)
    expect(proxy.to_javascript).to eql('SomeClass.someObject().someFunction()')
  end
  
  it "can return a new proxy for an object returned by a specified function with arguments" do
    proxy = subject.proxy_for(:someFunction, function_args: [1, 2, 3])
    expect(proxy.to_javascript).to eql('SomeClass.someObject().someFunction(1, 2, 3)')
  end
end

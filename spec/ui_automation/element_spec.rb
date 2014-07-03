require 'spec_helper'

describe UIAutomation::Element do
  let(:executor) { double }
  let(:parent) { double }
  let(:window) { double }

  subject { UIAutomation::Element.new(executor, 'SomeClass.someElement()', parent, window) }
  
  it "exposes its parent" do
    expect(subject.parent).to eql(parent)
  end
  
  it "exposes its window" do
    expect(subject.window).to eql(window)
  end
  
  it "is valid when UIAElement.checkIsValid() is true" do
    expect_perform('checkIsValid()', true)
    expect(subject).to be_valid
  end
  
  it "is not valid when UIAElement.checkIsValid() is false" do
    expect_perform('checkIsValid()', false)
    expect(subject).not_to be_valid
  end
  
  it "is visible when UIAElement.isVisible() == 1" do
    expect_perform('isVisible()', 1)
    expect(subject).to be_visible
  end
  
  it "is not visible when UIAElement.isVisible() == 0" do
    expect_perform('isVisible()', 0)
    expect(subject).not_to be_visible
  end
  
  it "is visible when UIAElement.isEnabled() == 1" do
    expect_perform('isEnabled()', 1)
    expect(subject).to be_enabled
  end
  
  it "is not visible when UIAElement.isEnabled() == 0" do
    expect_perform('isEnabled()', 0)
    expect(subject).not_to be_enabled
  end
  
  it "has keyboard focus when UIAElement.hasKeyboardFocus() == 1" do
    expect_perform('hasKeyboardFocus()', 1)
    expect(subject.has_keyboard_focus?).to be true
  end
  
  it "does not have keyboard focus when UIAElement.hasKeyboardFocus() == 0" do
    expect_perform('hasKeyboardFocus()', 0)
    expect(subject.has_keyboard_focus?).to be false
  end
  
  it "can be tapped immediately" do
    expect_perform('tap()')
    subject.tap!
  end
  
  it { is_expected.to have_element_array_proxy(:ancestry) }
  it { is_expected.to have_element_array_proxy(:elements) }
  it { is_expected.to have_element_array_proxy(:scrollViews) }
  it { is_expected.to have_element_array_proxy(:webViews) }
  it { is_expected.to have_element_array_proxy(:tableViews).of_type(UIAutomation::TableView) }
  it { is_expected.to have_element_array_proxy(:buttons) }
  it { is_expected.to have_element_array_proxy(:staticTexts) }
  it { is_expected.to have_element_array_proxy(:textFields).of_type(UIAutomation::TextField) }
  it { is_expected.to have_element_array_proxy(:secureTextFields).of_type(UIAutomation::TextField) }
  it { is_expected.to have_element_array_proxy(:searchBars).of_type(UIAutomation::TextField) }
  it { is_expected.to have_element_array_proxy(:segmentedControls) }
  it { is_expected.to have_element_array_proxy(:switches) }
  
  def expect_perform(method, return_value = nil)
    expect(executor).to receive(:execute_script).with("#{subject.javascript}.#{method}").and_return(return_value)
  end
end

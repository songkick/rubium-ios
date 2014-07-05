require 'spec_helper'

describe UIAutomation::Element do
  let(:executor) { double }
  let(:parent) { double }
  let(:window) { double }

  subject { UIAutomation::Element.new(executor, '<element>', parent, window) }
  
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
  
  it { should have_proxy(:ancestry).to_element_array(".ancestry()") }
  it { should have_proxy(:elements).to_element_array(".elements()") }
  it { should have_proxy(:scroll_views).to_element_array(".scrollViews()") }
  it { should have_proxy(:web_views).to_element_array(".webViews()") }
  it { should have_proxy(:table_views).to_element_array(".tableViews()").of_type(UIAutomation::TableView) }
  it { should have_proxy(:buttons).to_element_array(".buttons()") }
  it { should have_proxy(:static_texts).to_element_array(".staticTexts()") }
  it { should have_proxy(:text_fields).to_element_array(".textFields()").of_type(UIAutomation::TextField) }
  it { should have_proxy(:secure_text_fields).to_element_array(".secureTextFields()").of_type(UIAutomation::TextField) }
  it { should have_proxy(:search_bars).to_element_array(".searchBars()").of_type(UIAutomation::TextField) }
  it { should have_proxy(:segmented_controls).to_element_array(".segmentedControls()") }
  it { should have_proxy(:switches).to_element_array(".switches()") }
  
  def expect_perform(method, return_value = nil)
    expect(executor).to receive(:execute_script).with("#{subject.javascript}.#{method}").and_return(return_value)
  end
end

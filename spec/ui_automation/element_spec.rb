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
  
  it { should have_proxy(:ancestry).to_element_array }
  it { should have_proxy(:elements).to_element_array }
  it { should have_proxy(:scroll_views).to_element_array(".scrollViews()") }
  it { should have_proxy(:web_views).to_element_array(".webViews()") }
  it { should have_proxy(:table_views).to_element_array(".tableViews()").of_type(UIAutomation::TableView) }
  it { should have_proxy(:buttons).to_element_array }
  it { should have_proxy(:static_texts).to_element_array(".staticTexts()") }
  it { should have_proxy(:text_fields).to_element_array(".textFields()").of_type(UIAutomation::TextField) }
  it { should have_proxy(:secure_text_fields).to_element_array(".secureTextFields()").of_type(UIAutomation::TextField) }
  it { should have_proxy(:search_bars).to_element_array(".searchBars()").of_type(UIAutomation::TextField) }
  it { should have_proxy(:segmented_controls).to_element_array(".segmentedControls()") }
  it { should have_proxy(:switches).to_element_array }
  it { should have_proxy(:activity_indicators).to_element_array(".activityIndicators()") }
  it { should have_proxy(:activity_view).to_element(".activityView()").of_type(UIAutomation::ActivityView) }
  it { should have_proxy(:collection_views).to_element_array(".collectionViews()") }
  it { should have_proxy(:images).to_element_array }
  it { should have_proxy(:links).to_element_array }
  it { should have_proxy(:page_indicators).to_element_array(".pageIndicators()") }
  it { should have_proxy(:pickers).to_element_array.of_type(UIAutomation::Picker) }
  it { should have_proxy(:popover).to_element.of_type(UIAutomation::Popover) }
  it { should have_proxy(:progress_indicators).to_element_array('.progressIndicators()') }
  it { should have_proxy(:sliders).to_element_array }
  it { should have_proxy(:text_views).to_element_array('.textViews()').of_type(UIAutomation::TextView) }
  it { should have_proxy(:tab_bar).to_element('.tabBar()').of_type(UIAutomation::TabBar) }
  it { should have_proxy(:navigation_bar).to_element('.navigationBar()').of_type(UIAutomation::NavigationBar) }
  it { should have_proxy(:toolbar).to_element }
  it { should have_proxy(:tab_bars).to_element_array('.tabBars()').of_type(UIAutomation::TabBar) }
  it { should have_proxy(:navigation_bars).to_element_array('.navigationBars()').of_type(UIAutomation::NavigationBar) }
  it { should have_proxy(:toolbars).to_element_array }
  
  def expect_perform(method, return_value = nil)
    expect(executor).to receive(:execute_script).with("#{subject.javascript}.#{method}").and_return(return_value)
  end
end

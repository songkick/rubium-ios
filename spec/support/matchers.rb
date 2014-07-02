RSpec::Matchers.define :be_remote_proxy_to do |javascript|
  match do |proxy|
    (matches_type?(proxy) && proxy.javascript == javascript)
  end
  
  chain :of_type do |expected_type_or_matcher|
    @expected_type = expected_type_or_matcher
  end
  
  def matches_type?(proxy)
    expected_type_of_matcher = @expected_type || UIAutomation::RemoteProxy
    
    if expected_type_of_matcher.respond_to?(:matches?)
      expected_type_of_matcher.matches?(proxy)
    else
      proxy.is_a?(expected_type_of_matcher)
    end
  end
end

RSpec::Matchers.alias_matcher :remote_proxy_to, :be_remote_proxy_to

RSpec::Matchers.define :have_element_array_proxy do |function|
  match do |element|
    proxy = element.__send__(@proxy_method || function.to_s.underscore)

    (proxy.is_a?(UIAutomation::ElementArray) && 
      matches_javascript?(proxy, element, function) &&
      matches_expected_type?(proxy))
  end
  
  chain :of_type do |element_type|
    @element_type = element_type
  end
  
  chain :as do |proxy_method|
    @proxy_method = proxy_method
  end
  
  description do
    "have an element array proxy for #{function}()"
  end
  
  def matches_javascript?(proxy, parent, function)
    proxy.to_javascript == "#{parent.to_javascript}.#{function}()"
  end
  
  def matches_expected_type?(proxy)
    expected_type = @element_type || UIAutomation::Element
    proxy.element_klass == expected_type
  end
end

RSpec::Matchers.define :have_element_proxy do |function|
  match do |element|
    proxy = element.__send__(@proxy_method || function.to_s.underscore)

    (proxy.is_a?(@element_type || UIAutomation::Element) && 
      matches_javascript?(proxy, element, function))
  end
  
  chain :of_type do |element_type|
    @element_type = element_type
  end
  
  chain :as do |proxy_method|
    @proxy_method = proxy_method
  end
  
  description do
    "have an element array proxy for #{function}()"
  end
  
  def matches_javascript?(proxy, parent, function)
    proxy.to_javascript == "#{parent.to_javascript}.#{function}()"
  end
end

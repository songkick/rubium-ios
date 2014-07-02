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

RSpec::Matchers.define :have_array_proxy do |proxy_method|
  match do |element|
    proxy = element.__send__(proxy_method)

    (proxy.is_a?(UIAutomation::RemoteProxy) && 
      matches_javascript?(proxy, element, @js_function || proxy_method) &&
      matches_expected_type?(proxy))
  end
  
  chain :to do |js_function|
    @js_function = js_function
  end
  
  chain :of_type do |element_type|
    @element_type = element_type
  end
  
  description do
    "have an element array proxy for #{@js_function || proxy_method}() when calling #{proxy_method}"
  end
  
  def matches_javascript?(proxy, parent, function)
    proxy.to_javascript == "#{parent.to_javascript}.#{function}()"
  end
  
  def matches_expected_type?(proxy)
    expected_type = @element_type || UIAutomation::Element
    proxy.element_klass == expected_type
  end
end

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

RSpec::Matchers.define :have_proxy do |proxy_method|
  match do |proxy|
    @expected_type ||= UIAutomation::Element

    if @element_array
      has_element_array_proxy?(proxy, proxy_method)
    else
      has_element_proxy?(proxy, proxy_method)
    end
  end

  chain :to_element do |javascript|
    @expected_javascript = javascript
  end

  chain :to_element_array do |javascript|
    @element_array = true
    @expected_javascript = javascript
  end

  chain :of_type do |element_type|
    @expected_type = element_type
  end
  
  description do
    "have proxy :#{proxy_method} => #{expected_proxy_description}"
  end

  failure_message do |actual|
    message = "expected #{actual} to #{description} but "

    if actual.respond_to?(proxy_method)
      message + "got #{actual.__send__(proxy_method)}"
    else
      message + "does not respond to :#{proxy_method}!"
    end
  end

  def has_element_proxy?(proxy, proxy_method)
    if proxy.respond_to?(proxy_method)
      expected_proxy = proxy.__send__(proxy_method)
      
      [(expected_proxy.to_javascript == "#{proxy}#{@expected_javascript}"),
        expected_proxy.is_a?(@expected_type)].all?
    end
  end

  def has_element_array_proxy?(proxy, proxy_method)
    if proxy.respond_to?(proxy_method)
      expected_proxy = proxy.__send__(proxy_method)
      
      [expected_proxy.is_a?(UIAutomation::ElementArray),
       expected_proxy.to_javascript == "#{proxy}#{@expected_javascript}",
       expected_proxy.element_klass == @expected_type].all?
    end
  end

  def expected_proxy_description
    proxy_description = @element_array ? "UIAutomation::ElementArray<#{@expected_type}>" : @expected_type
    "#{@expected_javascript} (#{proxy_description})"
  end
end

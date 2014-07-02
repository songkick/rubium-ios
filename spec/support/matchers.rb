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

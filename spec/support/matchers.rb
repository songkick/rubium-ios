RSpec::Matchers.define :be_remote_proxy_to do |javascript|
  @expected_type = UIAutomation::RemoteProxy
  
  match do |proxy|
    (proxy.is_a?(@expected_type) && proxy.javascript == javascript)
  end
  
  chain :of_type do |type|
    @expected_type = type
  end
end

RSpec::Matchers.alias_matcher :remote_proxy_to, :be_remote_proxy_to

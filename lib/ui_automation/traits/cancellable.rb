module UIAutomation
  module Traits
    module Cancellable
      # @return [UIAutomation::Element] The element's cancel button
      def cancel_button
        element_proxy_for(:cancelButton)
      end
    end
  end
end

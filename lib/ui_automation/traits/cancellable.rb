module UIAutomation
  module Traits
    # Defines methods for elements that can be cancelled using a cancel button.
    #
    module Cancellable
      # @return [UIAutomation::Element] The element's cancel button
      def cancel_button
        element_proxy_for(:cancelButton)
      end
    end
  end
end

# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class ShipmentInformation
        attr_reader :documents,
                    :number,
                    :pickup_request_number,
                    :total,
                    :bol_id,
                    :shipping_method,
                    :warnings

        def initialize(
          total:,
          bol_id:,
          number:,
          pickup_request_number: nil,
          documents: [],
          shipping_method: nil,
          warnings: nil
        )
          @total = total
          @bol_id = bol_id
          @number = number
          @pickup_request_number = pickup_request_number
          @documents = documents
          @shipping_method = shipping_method
          @warnings = warnings
        end
      end
    end
  end
end

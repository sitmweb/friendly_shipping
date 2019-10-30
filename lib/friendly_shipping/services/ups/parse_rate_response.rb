# frozen_string_literal: true

require 'friendly_shipping/services/ups/parse_xml_response'
require 'friendly_shipping/services/ups/parse_money_element'

module FriendlyShipping
  module Services
    class Ups
      class ParseRateResponse
        def self.call(request:, response:, shipment:)
          parsing_result = ParseXMLResponse.call(response.body, 'RatingServiceSelectionResponse')
          parsing_result.fmap do |xml|
            FriendlyShipping::ApiResult.new(
              build_rates(xml, shipment),
              original_request: request,
              original_response: response
            )
          end
        end

        def self.build_rates(xml, shipment)
          xml.root.css('> RatedShipment').map do |rated_shipment|
            service_code = rated_shipment.at('Service/Code').text
            shipping_method = CARRIER.shipping_methods.detect do |sm|
              sm.service_code == service_code && shipment.origin.country.in?(sm.origin_countries)
            end
            days_to_delivery = rated_shipment.at('GuaranteedDaysToDelivery').text.to_i

            total = ParseMoneyElement.call(rated_shipment.at('TotalCharges')).last
            insurance_price = ParseMoneyElement.call(rated_shipment.at('ServiceOptionsCharges'))&.last
            negotiated_rate = ParseMoneyElement.call(
              rated_shipment.at('NegotiatedRates/NetSummaryCharges/GrandTotal')
            )&.last

            FriendlyShipping::Rate.new(
              shipping_method: shipping_method,
              amounts: { total: total },
              warnings: [rated_shipment.at("RatedShipmentWarning")&.text].compact,
              errors: [],
              data: {
                insurance_price: insurance_price,
                negotiated_rate: negotiated_rate,
                days_to_delivery: days_to_delivery
              }
            )
          end
        end
      end
    end
  end
end

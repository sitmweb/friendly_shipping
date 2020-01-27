# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Usps
      class ChoosePackageRate
        class CannotDetermineRate < StandardError; end
        # Some shipping rates use 'Flat Rate Boxes', indicating that
        # they are available for ALL flat rate boxes.
        FLAT_RATE_BOX = /Flat Rate Box/i.freeze

        # Select the corresponding rate for a package from all the rates USPS returns to us
        #
        # @param [FriendlyShipping::ShippingMethod] shipping_method The shipping method we want to filter by
        # @param [Physical::Package] package The package we want to match with a rate
        # @param [Array<FriendlyShipping::Rate>] The rates we select from
        #
        # @return [FriendlyShipping::Rate] The rate that most closely matches our package
        def self.call(shipping_method, rates, package_options)
          # Keep all rates with the requested shipping method
          rates_with_this_shipping_method = rates.select { |r| r.shipping_method == shipping_method }

          # Keep only rates with the package type of this package
          rates_with_this_package_type = rates_with_this_shipping_method.select do |r|
            if r.shipping_method.service_code == "FIRST CLASS"
              r.data[:first_class_mail_type] == package_options.first_class_mail_type
            else
              r.data[:box_name] == package_options.box_name
            end
          end

          # Filter by our package's `hold_for_pickup` option
          rates_with_this_hold_for_pickup_option = rates_with_this_package_type.select do |r|
            r.data[:hold_for_pickup] == package_options.hold_for_pickup
          end

          # At this point, we have one or two rates left, and they're similar enough.
          # Once this poses an actual problem, we'll fix it.
          rates_with_this_hold_for_pickup_option.first
        end
      end
    end
  end
end

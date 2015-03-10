module Spree
  class Recurring < Spree::Base
    class StripeRecurring < Spree::Recurring
      module ApiHandler
        module SubscriptionApiHandler
          def subscribe(subscription)
            raise_invalid_object_error(subscription, Spree::Subscription)
            customer = subscription.user.find_or_create_stripe_customer(subscription.card_token)
            puts "subcribe() subscription handler customer is: #{customer}"
            puts "subcribe() subscription is: #{subscription}"
            # unless customer.nil?
              customer.subscriptions.create(plan: subscription.api_plan_id)
            # end
          end

          def unsubscribe(subscription)
            raise_invalid_object_error(subscription, Spree::Subscription)
            subscription.user.api_customer.cancel_subscription
          end
        end
      end
    end
  end
end

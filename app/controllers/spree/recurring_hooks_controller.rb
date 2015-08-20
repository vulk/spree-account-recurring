module Spree
  class RecurringHooksController < BaseController
    skip_before_filter :verify_authenticity_token
    
    before_action :authenticate_webhook
    before_action :find_subscription

    respond_to :json

    def handler
      @subscription_event = @subscription.events.build(subscription_event_params)
      if @subscription_event.save
        render_status_ok
      else
        render_status_failure
      end
    end

    private

    def event
      @event ||= (Rails.env.production? ? params.deep_dup : params.deep_dup[:recurring_hook])
    end
    
    def authenticate_webhook
      render_status_ok if event.blank? || (event[:livemode] != Rails.env.production?) || (!Spree::Recurring::StripeRecurring::WEBHOOKS.include?(event[:type]))
    end

    def find_subscription
      # fun fact about this function.
      #
      # its supposed to quit execution with a render ok (which would give a 200 status code.) 
      # that wouldn't piss of stripe and cause them to send you an email that says your endpoint is failing a million times
      #
      # ... unless it fails to find a user with an associated subscription lol not that I would know anything about that
      #
      @user = Spree.user_class.find_by(stripe_customer_id: event[:data][:object][:customer])
      return render_status_ok  if @user.blank?

      @subscription = @user.try(:subscription)
      return render_status_ok if @subscription.blank?
    end

    def retrieve_api_event
      @event = @subscription.provider.retrieve_event(event[:id])
    end

    def subscription_event_params
      if retrieve_api_event && event.data.object.customer == @subscription.user.stripe_customer_id
        { event_id: event.id, request_type: event.type, response: event.to_json }
      else
        {}
      end
    end

    def render_status_ok
      render text: '', status: 200
    end

    def render_status_failure
      render text: '', status: 403
    end
  end
end

class AddStripeCustomerIdToSpreeUsers < ActiveRecord::Migration
  # Added guard clause to first check for existence of custom User class before adding column for default Spree::User
  def change
    unless defined?(User)
      add_column :spree_users, :stripe_customer_id, :string
    end
    remove_column :spree_subscriptions, :card_customer_token
  end
end

class AddSpreeAccountRecurringFieldsToCustomUserTable < ActiveRecord::Migration
  # This migration is in place to satisfy the Custom User class and add necessary fields to enable gem to work
  def change
    if defined?(User)
      add_column "users", :stripe_customer_id, :string
    end
  end
end

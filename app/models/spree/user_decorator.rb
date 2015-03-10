# added conditional to safeguard from the default SpreeUser class if you choose
# to create or have a custom User class already.

if defined?(User)
  puts "using custom user"
  klass = User
else
  puts "found spree::user"
  klass = Spree::User
end
klass.class_eval do
  # has_many :subscriptions
  has_many :subscriptions, class_name: 'Spree::Subscription'

  def find_or_create_stripe_customer(token=nil)
    puts "adding stripe customer"
    puts "token is: #{token}"
    puts "stripe_customer_id is: #{stripe_customer_id}"
    puts "user id is: #{id}"
    puts "is there a stripe_customer_id?: #{stripe_customer_id?}"
    return api_customer if stripe_customer_id? != true
    puts "after api_customer"
    customer = if token
      Stripe::Customer.create(description: email, email: email, card: token)
    else
      Stripe::Customer.create(description: email, email: email)
    end
    puts "customer is: #{customer}"
    update_column(:stripe_customer_id, customer.id)
    customer
  end

  def api_customer
    puts "getting stripe customer id ..."
    puts "stripe_customer_id is: #{stripe_customer_id}"
    Stripe::Customer.retrieve(stripe_customer_id)
  end
end

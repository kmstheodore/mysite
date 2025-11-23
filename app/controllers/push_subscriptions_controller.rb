class PushSubscriptionsController < ApplicationController
  # Disable verify_authenticity_token if you have issues, but passing X-CSRF-Token in fetch is better practice.

  def create
    # The 'keys' param comes from the JS subscription object
    keys = params[:keys] || {}

    subscription = WebPushSubscription.find_or_initialize_by(
      endpoint: params[:endpoint],
      user: current_user
    )

    subscription.update!(
      p256dh_key: keys[:p256dh],
      auth_key: keys[:auth]
    )

    head :ok
  end
end
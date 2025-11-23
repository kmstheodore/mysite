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
  def test_send
    # Grab the user's latest subscription
    # Note: In a real app, you might want to send to ALL user subscriptions
    sub = current_user.web_push_subscriptions.last

    if sub
      WebPush.payload_send(
        message: JSON.generate({
                                 title: "Render Test",
                                 body: "Hello from Production! It works!",
                                 url: "/about"
                               }),
        endpoint: sub.endpoint,
        p256dh: sub.p256dh_key,
        auth: sub.auth_key,
        vapid: {
          subject: Rails.application.credentials.vapid.subject,
          public_key: Rails.application.credentials.vapid.public_key,
          private_key: Rails.application.credentials.vapid.private_key
        }
      )
      redirect_back fallback_location: root_path, notice: "Notification sent!"
    else
      redirect_back fallback_location: root_path, alert: "No subscription found. Click 'Turn on' first."
    end
  rescue WebPush::InvalidSubscription, WebPush::ExpiredSubscription
    sub&.destroy
    redirect_back fallback_location: root_path, alert: "Subscription invalid. Please refresh and re-subscribe."
  end
end

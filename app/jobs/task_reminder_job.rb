# app/jobs/task_reminder_job.rb
class TaskReminderJob < ApplicationJob
  queue_as :default

  def perform(task_id, expected_strike_time_str)
    task = Task.find_by(id: task_id)

    # 1. Guard: Task must exist and not be complete
    return unless task
    return if task.complete?

    # 2. Guard: Time Check (Idempotency)
    # If the user changed the time, task.strike will differ from the job's stored time.
    # We convert to string/integer for safe comparison.
    return if task.strike.to_i != Time.zone.parse(expected_strike_time_str).to_i

    # 3. Send to all user subscriptions
    task.user.web_push_subscriptions.each do |sub|
      begin
        WebPush.payload_send(
          message: JSON.generate({
                                   title: "Task Due!",
                                   body: "It is time for: #{task.name}",
                                   icon: "/icon.png",
                                   data: { url: "/tasks" } # Opens the tasks page on click
                                 }),
          endpoint: sub.endpoint,
          p256dh: sub.p256dh_key, # Matches your schema
          auth: sub.auth_key,     # Matches your schema
          vapid: {
            subject: Rails.application.credentials.vapid.subject,
            public_key: Rails.application.credentials.vapid.public_key,
            private_key: Rails.application.credentials.vapid.private_key
          }
        )
      rescue WebPush::InvalidSubscription, WebPush::ExpiredSubscription
        # Cleanup dead subscriptions automatically
        sub.destroy
      end
    end
  end
end
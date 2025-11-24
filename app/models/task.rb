class Task < ApplicationRecord
  belongs_to :user

  # Schedule the job after the task is saved, but only if the time changed
  after_save_commit :schedule_reminder, if: :saved_change_to_strike?

  private

  def schedule_reminder
    return unless strike.present? && strike > Time.current

    # Solid Queue allows 'wait_until'.
    # We pass the strike time as a STRING to ensure it serializes safely for the comparison later.
    TaskReminderJob.set(wait_until: strike).perform_later(id, strike.iso8601)
  end
end
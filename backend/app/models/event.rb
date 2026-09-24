class Event < ApplicationRecord
  enum :status, { scheduled: "scheduled", in_progress: "in_progress", done: "done" }, default: :scheduled

  validates :title, presence: true
  validates :start_date, presence: true
  validate :end_date_not_before_start_date

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :ordered_by_start_date, ->(direction = :asc) { order(start_date: direction) }

  private

  def end_date_not_before_start_date
    return if end_date.blank? || start_date.blank?

    errors.add(:end_date, "は開始日以降の日付にしてください") if end_date < start_date
  end
end

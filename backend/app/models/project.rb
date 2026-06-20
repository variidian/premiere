class Project < ApplicationRecord
  belongs_to :user
  has_many :devlogs, dependent: :nullify

  STATUSES = %w[not_yet_shipped pending_approval approved rejected].freeze

  validates :name, :description, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :ship_fields_are_complete, if: -> { status == 'pending_approval' }

  scope :submitted_or_accepted, -> { where(status: %w[pending_approval approved]).order(updated_at: :desc) }
  scope :approved, -> { where(status: 'approved').order(updated_at: :desc) }

  private

  def ship_fields_are_complete
    required_fields = {
      repository_url: repository_url,
      demo_url: demo_url,
      image_url: image_url,
      hackatime_project: hackatime_project,
      hackatime_hours: hackatime_hours
    }

    required_fields.each do |field, value|
      errors.add(field, "must be filled before shipping") if value.blank?
    end
  end
end

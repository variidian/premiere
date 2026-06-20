class User < ApplicationRecord
    before_create :generate_token #auto runs before a new user is saved
    has_many :projects, dependent: :destroy
    has_many :devlogs, dependent: :destroy

    def admin?
      return true if admin

      admin_slack_ids = ENV.fetch('ADMIN_SLACK_IDS', 'U082ZLXSU10').split(',').map(&:strip)
      admin_emails = ENV.fetch('ADMIN_EMAILS', '').split(',').map(&:strip)
      admin_slack_ids.include?(slack_id) || admin_emails.include?(email)
    end
  
    private
  
    def generate_token
      self.token = SecureRandom.urlsafe_base64(32) #generates a random string and sets it as user.token
    end
  end

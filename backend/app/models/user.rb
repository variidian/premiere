class User < ApplicationRecord
    before_create :generate_token #auto runs before a new user is saved
  
    private
  
    def generate_token
      self.token = SecureRandom.urlsafe_base64(32) #generates a random string and sets it as user.token
    end
  end
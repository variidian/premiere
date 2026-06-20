class Devlog < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true

  validates :content, presence: true
end

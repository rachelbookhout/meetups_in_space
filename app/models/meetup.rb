class Meetup < ActiveRecord::Base
  has_many :members
  validates :name, :description, :location, presence: true
end

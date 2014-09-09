class Meetup < ActiveRecord::Base
  validates :name, :description, :location, presence: true
end

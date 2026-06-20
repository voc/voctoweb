class Organisation < ApplicationRecord
  has_and_belongs_to_many :conferences, join_table: 'conferences_organizers'

  validates :name, presence: true, uniqueness: true
end

module Frontend
  class Conference < ::Conference
    has_many :events, -> { order(release_date: :desc, id: :desc) }, class_name: 'Frontend::Event'
    has_many :recordings, through: :events
  end
end

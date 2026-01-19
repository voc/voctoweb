module Frontend
  class Recording < ::Recording
    belongs_to :event, class_name: 'Frontend::Event'
  end
end

class MirrorBrain < ActiveRecord::Base
    self.abstract_class = true
    self.establish_connection :mirrorbrain
end

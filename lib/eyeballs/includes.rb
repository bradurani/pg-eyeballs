module Eyeballs::RelationMixin
  def eyeballs
    Eyeballs::Inspector.new(self)
  end
end

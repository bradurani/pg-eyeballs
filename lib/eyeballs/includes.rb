module RelationMixin
  def eyeballs
    Eyeballs::Inspector.new(self)
  end
end

ActiveRecord::Relation.include RelationMixin

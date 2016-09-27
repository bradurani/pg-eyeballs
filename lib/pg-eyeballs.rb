require 'active_record'
require 'pg'

module Eyeballs
end

Dir[File.join(File.dirname(__FILE__), 'eyeballs', '*.rb')].each {|file| require file }

ActiveRecord::Relation.include Eyeballs::RelationMixin

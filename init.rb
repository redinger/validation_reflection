
require 'boiler_plate/validation_reflection'

ActiveRecord::Base.class_eval do
  include BoilerPlate::ActiveRecordExtensions::ValidationReflection
end

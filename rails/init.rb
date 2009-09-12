ActiveRecord::Base.class_eval do
  include ActiveRecordExtensions::ValidationReflection
  ActiveRecordExtensions::ValidationReflection.load_config
  ActiveRecordExtensions::ValidationReflection.install(self)
end

#--
# Copyright (c) 2006, Michael Schuerig, michael@schuerig.de
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++


require 'active_record/reflection'

# Based on code by Sebastian Kanthak
# See http://dev.rubyonrails.org/ticket/861
module BoilerPlate # :nodoc:
  module ActiveRecordExtensions # :nodoc:
    module ValidationReflection # :nodoc:
      VALIDATIONS = %w(
         validates_acceptance_of
         validates_associated
         validates_confirmation_of
         validates_exclusion_of
         validates_format_of
         validates_inclusion_of
         validates_length_of
         validates_numericality_of
         validates_presence_of
         validates_uniqueness_of
      ).freeze

      def self.included(base)
        return if base.kind_of? BoilerPlate::ActiveRecordExtensions::ValidationReflection::ClassMethods
        base.extend(ClassMethods)

        for validation_type in VALIDATIONS
          base.module_eval <<-"end_eval"
            class << self
              alias_method :#{validation_type}_without_reflection, :#{validation_type}

              def #{validation_type}_with_reflection(*attr_names)
                #{validation_type}_without_reflection(*attr_names)
                configuration = attr_names.last.is_a?(Hash) ? attr_names.pop : nil
                for attr_name in attr_names
                  write_inheritable_array "validations", [ ActiveRecord::Reflection::MacroReflection.new(:#{validation_type}, attr_name, configuration, self) ]
                end
              end

              alias_method :#{validation_type}, :#{validation_type}_with_reflection
            end
          end_eval
        end
      end

      module ClassMethods

        # Returns an array of MacroReflection objects for all validations in the class
        def reflect_on_all_validations
          read_inheritable_attribute("validations") || []
        end

        # Returns an array of MacroReflection objects for all validations defined for the field +attr_name+ (expects a symbol)
        def reflect_on_validations_for(attr_name)
          reflect_on_all_validations.find_all do |reflection|
            reflection.name.to_s == attr_name.to_s
          end
        end

      end

    end
  end
end

# from Demetrio Nunes
# Modified by Andy Singleton to use different GUID generator
# Further modified by Brian Morearty to:
# 1. optionally use the MySQL GUID generator
# 2. respect the "column" option
# 3. set the id before create instead of after initialize
#
# MIT License

#require 'uuid22'
#require 'uuid_mysql'

module Usesguid
  module ActiveRecordExtensions
    
    #def self.append_features( base )
    def self.included( base )
      super
      base.extend( ClassMethods )
    end

    
    module ClassMethods
      
      # guid_generator can be :timestamp or :mysql
      def guid_generator=(generator); class_eval { @guid_generator = generator } end
      def guid_generator; class_eval { @guid_generator || :timestamp } end
 
      def usesguid(options = {})
                
        class_eval do
          set_primary_key options[:column] if options[:column]
          
          before_create :assign_guid

          # Give this record a guid id.  Public method so people can call it before save if necessary.
          def assign_guid
            # This could probably be prettied up a little:
            if ActiveRecord::Base.guid_generator == :random36
              # generate full 36-character RFC 4122 string (e.g., "f81d4fae-7dec-11d0-a765-00a0c91e6bf6")
              self[self.class.primary_key] ||= UUID.random_create().to_s
              return
            end
            self[self.class.primary_key] ||= case ActiveRecord::Base.guid_generator
              when :mysql then UUIDTools::UUID.mysql_create(self.connection)
              when :timestamp then UUIDTools::UUID.timestamp_create()
              when :random then UUIDTools::UUID.random_create()  
              else raise "Unrecognized guid generator '#{ActiveRecord::Base.guid_generator.to_s}'"
            end.to_s22
          end

        end

      end

    end
    
  end
end
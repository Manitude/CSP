# -*- encoding : utf-8 -*-
# Taken from http://blog.sbf5.com/?p=39
# Basically, when an object is deserialized and the class that was serialized
# doesn't exist, then you get back a YAML object, rather than the object you
# wanted.  The fix below will use Rails' autoloading to load the class if it's
# not already there.

# Ruby 1.9 does not have YAML::Syck
if RUBY_VERSION =~ /^1\.8/
  YAML::Syck::Resolver.class_eval do
    def transfer_with_autoload(type, val)
      match = type.match(/object:(\w+(?:::\w+)*)/)
      begin
        match && match[1].constantize
      rescue NameError
        # Ignore the name error.  We'll then behave like it used to if we truly
        # cannot find the class
      end
      transfer_without_autoload(type, val)
    end
    alias_method_chain :transfer, :autoload
  end
end

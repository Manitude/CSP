# -*- encoding : utf-8 -*-
module SimpleHTTP
  class Client

    Request.subclasses.each do |verb_class|
      verb = verb_class.to_s.constantize.verb
      # Defines the instance methods on the client to make requests. Using string eval because
      # we can't define default arguments like args = {} when using define_method.
      #
      # Each HTTP verb gets an instance method on the SimpleHTTP::Client class that takes the
      # following arguments:
      # path - Required. The path including query string to make the request to.
      # args - Optional. A hash of arguments such as extra headers. Essentially gets forwarded
      # to SimpleHTTP::Client::Request. See the constructor of that class for available args.
      #
      # Each HTTP verb also gets a singleton method on the SimpleHTTP::Client class so that
      # initialization of a SimpleHTTP::Client object isn't necessary for simple one off HTTP
      # requests. These methods take the following arguments:
      # path_or_url - Required. Either the path including query string to make the request to, or
      #               the whole URL including hostname.
      # args - Optional. Any other arguments to go to the SimpleHTTP::Client::Request constructor.
      class_eval %Q[
        def #{verb}(path_or_url, args = {})
          response = delegate_instance_request(:'#{verb}', path_or_url, args)
          (block_given?) ? yield(response) : response
        end

        def self.#{verb}(path_or_url, args = {})
          response = delegate_singleton_from_path_or_url(:'#{verb}', path_or_url, args)
          (block_given?) ? yield(response) : response
        end
        ], __FILE__, __LINE__
    end

  end   # Client
end


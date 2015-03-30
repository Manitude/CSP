module Delayed
  module Backend
    module Base
      module ClassMethods
        # Add a job to the queue
        def enqueue(*args)
          object = args.shift
          unless object.respond_to?(:perform)
            raise ArgumentError, 'Cannot enqueue items which do not respond to perform'
          end

          priority = args.first || 5
          run_at   = args[1]
          self.create(:payload_object => object, :priority => priority.to_i, :run_at => run_at)
        end
      end
    end
  end
end
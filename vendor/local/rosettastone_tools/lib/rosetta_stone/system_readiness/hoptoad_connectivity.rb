# -*- encoding : utf-8 -*-

if defined?(HoptoadNotifier)
  class SystemReadiness::HoptoadConnectivity < SystemReadiness::Base
    class SystemReadinessCheck < Exception; end
    class << self
      def verify
        #Under normal circumstances, this will return the number of the hoptoad record
        #At the point of this being written, if you notify for a record marked as Chronic, Hoptoad
        #will 500, resulting in a nil response here.
        if HoptoadNotifier.notify(SystemReadinessCheck.new).nil?
          return false, "It appears that something is wrong with hoptoad connectivity. (If the error in Hoptoad is marked as 'Chronic', you may get a false positive here due to a Hoptoad bug - use 'Noted' instead)."
        else
          return true, nil
        end
      end
    end
  end
end

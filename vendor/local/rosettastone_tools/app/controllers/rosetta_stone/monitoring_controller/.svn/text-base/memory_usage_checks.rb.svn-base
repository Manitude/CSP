# This module is intended to be included into the monitoring controller in your app to provide
# checks for monitoring memory usage on the app tier.
module RosettaStone
  module MonitoringController
    module MemoryUsageChecks

      def self.included(controller_class)

        controller_class.define_check(:memory_usage_resident, {
          :description => "Resident Set Size (RSS/RSIZE) memory usage of this process in kilobytes",
          :type => 'memory_usage',
        }) do
          respond_with(RosettaStone::MemUsage.resident)
        end

        controller_class.define_check(:memory_usage_virtual, {
          :description => "Virtual Size (VSZ/VSIZE) memory usage of this process in kilobytes",
          :type => 'memory_usage',
        }) do
          respond_with(RosettaStone::MemUsage.virtual)
        end
      end
    end
  end
end
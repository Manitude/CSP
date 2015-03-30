# -*- encoding : utf-8 -*-

class SystemReadiness::LogWriteability < SystemReadiness::Base
  class << self
    def verify
      if Framework.logger.respond_to?(:outputters) && !Framework.logger.outputters.empty?
        # an attempt at supporting Log4r (which is used by Goliath)
        log_file = Framework.logger.outputters.first.filename
        log_dir = File.dirname(log_file)
      else
        if defined?(ActiveSupport::TaggedLogging) && Framework.logger.is_a?(ActiveSupport::TaggedLogging)
          if logger = Framework.logger.instance_variable_get('@logger')
            log_file = logger.instance_variable_get('@log_dest')
          elsif logdev =  Framework.logger.instance_variable_get('@logdev')
            log_file = logdev.instance_variable_get('@dev')
          end
          log_dir = File.dirname(log_file.path)
        else
          log_file = Framework.logger.instance_variable_get('@log')
          # if @log is not owned by deploy, log_file is IO which causes an exception
          return false, "log file (#{log_file}) not writeable?" unless log_file.is_a?(File)
          log_dir = File.dirname(log_file.path)
        end
        return false, "log file (#{log_file}) not writeable?" unless log_file.stat.writable?
      end
      return false, "log directory (#{log_dir}) not writeable?" unless File.stat(log_dir).writable?
      return true, nil
    end
  end
end

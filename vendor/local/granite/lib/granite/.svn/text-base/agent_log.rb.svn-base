# Relies on Ruby's Logger class and Rails setting up a logger object. The level is set by Granite::Agent

module Granite::AgentLog

  # these messages go to stdout, which is usually redirected to a log file named after the agent
  # log levels defined in ruby's logger.rb:
  # +FATAL+:: an unhandleable error that results in a program crash
  # +ERROR+:: a handleable error condition
  # +WARN+::  a warning
  # +INFO+::  generic (useful) information about system operation
  # +DEBUG+:: low-level information for developers
  #
  # level can be an integer (like Logger::WARN) or a string (like 'warn' or 'WARN')
  
  MILLIS_BETWEEN_LOG_STATS = 30 * 1000 #30 seconds

  def agent_log(message, level = Logger::INFO)
    severity = level.is_a?(Integer) ? level : level_string_to_severity(level)
    return if severity < log_level

    #reopen the log file every MILLIS_BETWEEN_LOG_STATS if its inode has changed
    now = Time.now.milliseconds
    if (klass.log_io.is_a?(File) && (now - @time_last_checked_log_stat) > MILLIS_BETWEEN_LOG_STATS)
      begin
        inode = File::Stat.new(klass.log_io.path).ino
        if (inode != @inode)
          reopen_log_io
        end
      rescue
        reopen_log_io
      end
    end

    klass.log_io.puts "#{Time.now.to_s(:db)} - #{klass} (pid #{Process.pid}): #{severity_label(severity)}: #{message}"
  end

  def reopen_log_io
    return unless klass.log_io.is_a?(File)
    klass.log_io.reopen(klass.log_io.path)
    @inode = klass.log_io.stat.ino
  end

  def setup_logger_output(output)
    klass.log_io = output
    klass.log_io.sync = true#flush immediately

        
    #redirect STDOUT and STDERR to the log file
    if !klass.log_io.is_a?(StringIO)
      @time_last_checked_log_stat = Time.now.milliseconds
      @inode = klass.log_io.stat.ino
      $stdout.reopen(klass.log_io)
      $stderr.reopen($stdout)
    end
  end

  def severity_label(severity)
    Logger::SEV_LABEL[severity.to_i] || 'ANY'
  end

  def level_string_to_severity(level_string)
    "Logger::Severity::#{level_string.to_s.upcase}".constantize rescue 0
  end

  # you can override this if you want, but we'll stick with what Rails is using by default
  def log_level
    logger.level
  end

  # def agent_log_debug
  # def agent_log_info
  # def agent_log_warn
  # def agent_log_error
  # def agent_log_fatal
  Logger::SEV_LABEL.each do |severity|
    define_method("agent_log_#{severity.downcase}") do |message|
      agent_log(message, level_string_to_severity(severity))
    end
  end
end

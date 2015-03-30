module RosettaStone::ForkWithDatabase
  # This forks the current running process and gives you ActiveRecord database
  # access in the fork. Specifically, it does the following:
  #
  #  * closes the current connection
  #  * forks and establishes a new connection in each forked process
  #  * yields the block in each fork and calls Kernel#exit! (bypassing, e.g., at_exit directives)
  #
  # This is NOT recommended/tested for use if any of the following are true:
  #
  #  * the active connection is currently in a transaction
  #  * the active connection is expected to be maintained
  #  * there are other active things in the process that cannot survive a fork
  #
  # fork_with_database also blocks until all of the forked processes finish. It
  # also rescues exceptions produced by the block and bubbles up the exception
  # report, causing fork_with_database to raise in the main thread. Exception
  # backtraces are stored in files.
  #
  # When this is called when ActiveRecord is not in use/not defined, it skips
  # the connection management step.
  #
  def fork_with_database(num = 2, &block)
    tempfiles = Dir[File.join(Rails.root, 'tmp', 'concurrency_dump_*')]
    using_active_record = defined?(ActiveRecord)
    config = ActiveRecord::Base.remove_connection if using_active_record
    fork_pids = Array.new(num).map do
      fork do
        begin
          ActiveRecord::Base.establish_connection(config) if using_active_record
          begin
            yield
          rescue Exception => e
            # avoiding doing any more logic than just Marhsaling and dumping in
            # the forked process (e.g., printing/logging errors, interacting
            # otherwise with the outside world). The Marshaled exception is then
            # in turn accessible to the parent process (the main test process),
            # which can then be managed interactively.
            File.open(File.join(Rails.root, 'tmp', "concurrency_dump_#{Process.pid}"), 'wb') do |f|
              f.write(Marshal.dump(e))
            end
          end
        ensure
          ActiveRecord::Base.remove_connection if using_active_record
          exit!
        end
      end
    end
    Process.waitall
    ActiveRecord::Base.establish_connection(config) if using_active_record

    formatted_exception_messages = []
    fork_pids.each do |pid|
      dumpfile = File.join(Rails.root, 'tmp', "concurrency_dump_#{pid}")
      if File.exists?(dumpfile)
        File.open(dumpfile, 'rb') do |f|
          e = Marshal.load(f.read)
          tracefile = File.join(Rails.root, 'tmp', "concurrency_dump_#{pid}.backtrace")
          File.open(tracefile, 'w') { |g| g.write(e.backtrace.join("\n")) }
          formatted_exception_messages << "  * #{e.message} - backtrace in #{tracefile}"
        end
      end
    end

    num_exceptions = formatted_exception_messages.length
    if num_exceptions > 0
      raise "Forks encountered #{num_exceptions} errors:\n#{formatted_exception_messages.join("\n")}"
    end
  end
end

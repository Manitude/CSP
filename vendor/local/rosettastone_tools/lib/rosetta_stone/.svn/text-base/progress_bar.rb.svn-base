# -*- encoding : utf-8 -*-

# Simple spinner/progress bar and elapsed time/estimated time remaining
# indicator designed for long-running tasks run on the console.

module RosettaStone
  class ProgressBar
    SPINNER = ['-', '\\', '|', '/', '-', '\\', '|', '/']

    def initialize(expected_count, out = $stdout, columns = ENV['COLUMNS'])
      @out = out
      @columns = (columns || 80).to_i - 2
      @spinner_pos = 0
      @counter = 0
      @start_time = Time.now.to_f
      @total_count = expected_count
    end

    def spin
      @spinner_pos += 1
      @spinner_pos = 0 if @spinner_pos >= self.class::SPINNER.size
      @counter += 1

      time_now = Time.now.to_f
      hours_elapsed = ((time_now - @start_time) / 3600).to_i
      minutes_elapsed = ((time_now - @start_time) % 3600 / 60).to_i

      time_left = ((time_now - @start_time) / @counter * (@total_count - @counter)).to_i
      hours_left = time_left / 3600
      minutes_left = time_left % 3600 / 60

      time_string = '%02dh%02dm / %02dh%02dm' % [hours_elapsed, minutes_elapsed, hours_left, minutes_left]

      width = @columns - time_string.length - 1
      bar_width = (width - (@total_count - @counter).to_f / @total_count * width).to_i
      print("\r#{time_string} #{'=' * bar_width}#{' ' * (width - bar_width)} #{self.class::SPINNER[@spinner_pos]}")
    end

    def self.map_with_spin(obj, label, expected_count, options = {}, &block)
      out = options.fetch(:out, $stdout)
      if !out.tty? or !options.fetch(:verbose, false)
        return obj.map(&block)
      end
      progress_bar = self.new(expected_count, out, options.fetch(:columns, ENV['COLUMNS']))
      puts label
      res = obj.map do |ii|
        progress_bar.spin
        obj.instance_eval do
          block.call(ii)
        end
      end
      puts 
      res
    end
  end
end

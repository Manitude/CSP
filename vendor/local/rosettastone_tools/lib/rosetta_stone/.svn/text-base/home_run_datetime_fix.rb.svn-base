# Work Item 25631
# This is only loaded if you have home_run (date_ext) in your app.
# It works around a problem in that C code where the "sec" value
# seems to get set (rounded?) incorrectly.
# DateTime#to_time for a value with an odd number of seconds will
# come back with a time representing the previous second.
#
# Note: other code using "sec" on a DateTime could still be hosed,
# and we didn't attempt to trace down the actual problem in the C
# code.
#
# Note: this may be obsolete with some work that rajesh did
# in home_run.
begin
  HomeRun # will raise NameError in apps that don't have this
  true
rescue NameError
  false
end && begin
  class DateTime

    def to_time
      self.offset == 0 ? ::Time.at(to_i) : self
    end

  end
end

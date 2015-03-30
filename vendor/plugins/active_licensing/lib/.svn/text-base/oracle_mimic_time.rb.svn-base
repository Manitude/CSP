# -*- encoding : utf-8 -*-
# Extends the Ruby built-in Time class in order to add the methods needed to mimic the
# Oracle ADD_MONTHS function.
#
# For online subscriptions sold on the website, both the e-commerce software and Oracle
# have to be able to create/extend licenses which expire/renew on a given end-date.  Oracle
# uses the built-in ADD_MONTHS function to calculate the end-date, given a start-date and
# the purchased length (in months) of the subscription product.
#
# <b>WARNING:</b> The add_months method is not a general replacement for the Oracle ADD_MONTHS
# function.  It is meant to be used only in conjunction with the LicenseServerInterface
# class, and has not been tested for any other purpose.

class OracleMimicTime < Time

  # The number of seconds in a day, to enable advancing an OracleMimicTime by one day.
  SECONDS_PER_DAY = 60 * 60 * 24

  # Returns true if the OracleMimicTime instance is on the last day of the month; false
  # otherwise.  This is needed to support "month addition" operations done the same way
  # as Oracle (ADD_MONTHS function).
  def last_day?
    day_later = self + SECONDS_PER_DAY
    (self.month != day_later.month)
  end

  # Adds a number of months and returns the new time.
  #
  # The months parameter can't be greater than 12, with the current scheme.
  #
  # <b>IMPORTANT:</b> Possible DST complications in the calculations are avoided by doing all calculations based on twelve noon. The hour, minute, second
  # is then re-written in the final call to local, to set the time as appropriate.
  def add_months(months)
    timepiece = self.to_a
    timepiece[2], timepiece[1], timepiece[0] = 12, 0, 0
    timepiece[4] += months.to_i % 12
    timepiece[5] += months.to_i / 12
    if (timepiece[4] > 12)
      timepiece[4] -= 12
      timepiece[5] += 1
    end
    if (self.day > 27)
      timepiece[3] = 28
      loop do
        check = OracleMimicTime.local(timepiece[0], timepiece[1], timepiece[2], timepiece[3], timepiece[4],
                        timepiece[5], timepiece[6], timepiece[7], timepiece[8], timepiece[9])
        break if (not self.last_day? and (self.day == check.day))
        break if (check.last_day?)
        timepiece[3] += 1
      end
    end
    OracleMimicTime.local(sec, min, hour, timepiece[3], timepiece[4], timepiece[5], timepiece[6], timepiece[7], timepiece[8], timepiece[9])
  end
end

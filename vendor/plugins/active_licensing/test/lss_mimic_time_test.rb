# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))
require 'oracle_mimic_time'

class RosettaStone::ActiveLicensing::LssMimicTimeTest < Test::Unit::TestCase

  # Tests the last_day? method for all days in the range of January 1, 2005 to December 31, 2008.
  #
  def test_last_days
    with_utc_timezone do
      (2005..2008).each do |tyear|
        [["jan",1..31], ["feb",1..28], ["mar",1..31], ["apr",1..30], ["may",1..31], ["jun",1..30],
         ["jul",1..31], ["aug",1..31], ["sep",1..30], ["oct",1..31], ["nov",1..30], ["dec",1..31]].each do |tmonth, dayrange|
          dayrange.each do |tday|
            if (tday == dayrange.last)
              if (tmonth == "feb")
                if (tyear == 2008)
                  assert(! OracleMimicTime.local(tyear,tmonth,28).last_day?)
                  assert(OracleMimicTime.local(tyear,tmonth,29).last_day?)
                else
                  assert(OracleMimicTime.local(tyear,tmonth,28).last_day?)
                end
              else
                assert(OracleMimicTime.local(tyear,tmonth,tday).last_day?)
              end
            else
              assert(! OracleMimicTime.local(tyear,tmonth,tday).last_day?)
            end
          end
        end
      end
    end
  end

  # Tests the add_months method for adding 1 to 6 months to each day in the range of January 1, 2005 to
  # December 31, 2008.  It does this by first creating a time (t_create) and then adding the specified
  # number of months to that.  The resulting time is t_expire, and Ruby time methods are used to ensure
  # that the right number of months were added.  There are also checks to make sure that advancing months
  # always leaves the last_day? check with the same value for both t_create and t_expire.  There are also
  # checks to make sure that the time of day does not influence the result (because of daylight saving time
  # changes, etc.)
  #
  def test_add_months
    with_utc_timezone do
      (2005..2008).each do |tyear|
        [["jan",1..31], ["feb",1..28], ["mar",1..31], ["apr",1..30], ["may",1..31], ["jun",1..30],
         ["jul",1..31], ["aug",1..31], ["sep",1..30], ["oct",1..31], ["nov",1..30], ["dec",1..31]].each do |tmonth, dayrange|
          dayrange.each do |tday|
            (1..6).each do |tperiod|
              t_create = OracleMimicTime.local(tyear,tmonth,tday,12,0,0,0)
              t_expire = t_create.add_months(tperiod)
              assert_equal((12 + (t_expire.month % 12) - (t_create.month % 12)) % 12, tperiod, "Months advanced is wrong.")

              assert((t_create.day == t_expire.day) || t_create.last_day? || t_expire.last_day?, "Ending day is wrong.")

              t_expire_early = OracleMimicTime.local(tyear,tmonth,tday,0,30,0,0).add_months(tperiod)
              assert_equal(t_expire_early.year, t_expire.year, "Early time of day made a difference (year).")
              assert_equal(t_expire_early.month, t_expire.month, "Early time of day made a difference (month).")
              assert_equal(t_expire_early.day, t_expire.day, "Early time of day made a difference (day).")

              t_expire_late = OracleMimicTime.local(tyear,tmonth,tday,23,30,0,0).add_months(tperiod)
              assert_equal(t_expire_late.year, t_expire.year, "Late time of day made a difference (year).")
              assert_equal(t_expire_late.month, t_expire.month, "Late time of day made a difference (month).")
              assert_equal(t_expire_late.day, t_expire.day, "Late time of day made a difference (day).")
            end
          end
        end
        (1..6).each do |tperiod|
          t_create = OracleMimicTime.local(2008,2,29,12,0,0,0)
          t_expire = t_create.add_months(tperiod)
          assert_equal((12 + (t_expire.month % 12) - (t_create.month % 12)) % 12, tperiod, "Months advanced is wrong (LY).")

          assert((t_create.day == t_expire.day) || t_create.last_day? || t_expire.last_day?, "Ending day is wrong (LY).")

          t_expire_early = OracleMimicTime.local(2008,2,29,0,30,0,0).add_months(tperiod)
          assert_equal(t_expire_early.year, t_expire.year, "Early time of day made a difference (year,LY).")
          assert_equal(t_expire_early.month, t_expire.month, "Early time of day made a difference (month,LY).")
          assert_equal(t_expire_early.day, t_expire.day, "Early time of day made a difference (day,LY).")

          t_expire_late = OracleMimicTime.local(2008,2,29,23,30,0,0).add_months(tperiod)
          assert_equal(t_expire_late.year, t_expire.year, "Late time of day made a difference (year,LY).")
          assert_equal(t_expire_late.month, t_expire.month, "Late time of day made a difference (month,LY).")
          assert_equal(t_expire_late.day, t_expire.day, "Late time of day made a difference (day,LY).")
        end
      end
    end
  end
end

class FunctionToConvertTimezone < ActiveRecord::Migration
  def self.up
=begin
    execute("CREATE FUNCTION fn_GetTimeZone (input_date DATETIME) returns varchar(3)
              DETERMINISTIC
              RETURN 	CASE 	WHEN month(input_date) IN (4,5,6,7,8,9,10) THEN 'EDT'
                            WHEN month(input_date) IN (1,2,12) THEN 'EST'
                            WHEN month(input_date) IN (3) THEN 	CASE
                             	WHEN DAY(input_date) >  1 +(15-DAYOFWEEK(input_date - INTERVAL( DAYOFMONTH(input_date) - 1) day)) THEN 'EDT'
                              WHEN DAY(input_date) =  1 +(15-DAYOFWEEK(input_date - INTERVAL( DAYOFMONTH(input_date) - 1) day)) THEN CASE WHEN TIME(input_date) > '01:59:00' THEN 'EDT' ELSE 'EST' END
                              ELSE 'EST'
                            END
                            WHEN month(input_date) IN (11) THEN CASE 	WHEN DAY(input_date) <  1 +(8-DAYOFWEEK(input_date - INTERVAL( DAYOFMONTH(input_date) - 1) day)) THEN 'EDT'
                              WHEN DAY(input_date) =  1 +(8-DAYOFWEEK(input_date - INTERVAL( DAYOFMONTH(input_date) - 1) day)) THEN CASE WHEN TIME(input_date) <= '01:00:00' THEN 'EDT' ELSE 'EST' END
                              ELSE 'EST'
                            END
                            ELSE 'EDT'
                     END;")
=end
  end

  def self.down
=begin
    execute("DROP FUNCTION fn_GetTimeZone;")
=end
  end
end

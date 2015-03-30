require 'fileutils'
class Cronjob
	def self.mutex(name = '')
    begin
      yield if block_given?
    rescue Exception => e
      logger.info e.message
  	ensure
  		res = FileUtils.remove_file(File.dirname(__FILE__)+'/../tmp/' + name +'.lock', true)
      logger.info "\n*******Task #{name} has been unlocked at #{Time.now}********\n" if res
    end
	end
end

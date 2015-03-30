if defined?(Goliath) 
  Framework = Goliath
elsif defined? Rails
  Framework = Rails
elsif defined? StoneStream
  Framework = StoneStream
else
  raise RuntimeError.new("unsupported framework")
end

class << Framework
  # make an attempt to get a "version" of the application code.  this implementation only works
  # on cap-deployed instances, since it relies on the timestamp that capistrano puts into the
  # release directory name.  on other instances it will be 0
  def app_version
    @app_version ||= Pathname.new(Framework.root).realpath.split.last.to_s.to_i.tap do |version|
      if version == 0
        logger.error("No app_version detected from Framework.root.  This is only a concern on cap-deployed instances.")
      else
        logger.info("Detected app_version of #{version}")
      end
    end
  end
end
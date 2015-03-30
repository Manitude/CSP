module HoptoadNotifier
  class << self
    def notify(exception, opts = {})
      if exception.instance_of?(String)
        exception = Exception.new(exception)
      end
      send_notice(build_notice_for(exception, opts))
    end
    
  end
end

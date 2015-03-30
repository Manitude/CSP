module ProductLanguages
  class << self
    alias_method :old_display_name_from_code_and_version, :display_name_from_code_and_version

    def display_name_from_code_and_version(language_code, version, options = {})
      return "Advanced English" if language_code == 'KLE'
      return self.old_display_name_from_code_and_version(language_code, version, options)
    end
  end
end

class Delayed::Worker
  alias_method :original_handle_failed_job, :handle_failed_job

  def handle_failed_job(job, error)
    HoptoadNotifier.notify(error,{:parameters => {:job => job.attributes}})
    if Rails.env == "test"
      puts "FAILED DELAYED JOB"
      puts job
      puts error
      puts error.backtrace
    end
    original_handle_failed_job(job, error)
  end
end

# adding custom 'myself' method to return the self
# something like "sathish".myself returns "sathish"
# Thanks to #{"rajesh".myself} for the awesome idea.
class Object
  def myself
    self
  end
end
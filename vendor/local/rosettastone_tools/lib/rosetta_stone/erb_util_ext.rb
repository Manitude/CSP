# -*- encoding : utf-8 -*-

class ERB
  module Util

    # it's unclear whether this is a bug or intentional, but json_escape in
    # Rails 2.2.2 removes all double quotes.  Use this hack if you want to
    # keep them.
    # See also http://rails.lighthouseapp.com/projects/8994/tickets/1485-json_escape-eats-away-double-quotes
    def json_escape_that_leaves_double_quote_intact(s)
      s.to_s.gsub(/[&><]/) { |special| JSON_ESCAPE[special] }
    end
    module_function :json_escape_that_leaves_double_quote_intact

  end
end

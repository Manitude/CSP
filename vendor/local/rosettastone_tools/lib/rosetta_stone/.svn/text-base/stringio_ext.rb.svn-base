# -*- encoding : utf-8 -*-
# unfortunately we still have 1.8.6
require 'stringio'
if RUBY_VERSION < "1.8.7"
  class StringIO
    alias_method :getbyte, :getc
  end
end


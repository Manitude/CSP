# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2011 Rosetta Stone
# License:: All rights reserved.

# Work Item 27902
# Rails versions starting at 2.0 and up to (at least) 3.0 disable auto_flushing whenever the Rails environment
# is production.  This is great in that it generally prevents interleaving of log entries from different
# requests, but awful behavior for non-web-server contexts (such as rake tasks, console operations, etc.) because
# log messages will not appear until 1000 log entries have accumulated.
#
# This file nuances the behavior a bit by re-enabling auto_flushing for scripts and such.  We try to detect
# web server environments (mod_fcgid and Passenger) and leave the default buffered logging behavior in those
# contexts.
require 'rosetta_stone/execution_context'
if logger.respond_to?(:auto_flushing=) && Rails.production? && !RosettaStone::ExecutionContext.is_web_server?
  logger.auto_flushing = true
end

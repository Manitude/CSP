# work item 28078
#
# So, in Rails 2, if you have a 'flash' object in your session, it gets marshaled as an ActionController::Flash::FlashHash.  In Rails 3, it's an ActionDispatch::Flash::FlashHash.  Moreover, some of the internals of this class have changed (@used is now a Set, for instance) in a way that does not allow the FlashHash objects from old sessions to be loadable in Rails 3.
#
# This solution involves redefining ActionController::Flash::FlashHash so that the session object can be unmarshalled at all and hotfixing the session loading middleware to trash it if it is of class ActionController::Flash::FlashHash.
#
# Remember to add an integration test for this functionality in your application. Example:
#
# https://opx.lan.flt/browser/update_service/trunk/test/integration/flashdata_compatibility_test.rb?rev=36545
#
class ActionController::Flash::FlashHash < ActionDispatch::Flash::FlashHash
end

module RosettaStone
  class FlashdataCompatibility
    def initialize(app)
      @app = app
    end

    def call(env)
      if (session = env['rack.session']) && session['flash'].is_a?(ActionController::Flash::FlashHash)
        logger.info('Flashdata was found by was of class ActionController::Flash::FlashHash (Rails 2 style). Removing.')
        session.delete('flash')
      end
      @app.call(env)
    end
  end
end

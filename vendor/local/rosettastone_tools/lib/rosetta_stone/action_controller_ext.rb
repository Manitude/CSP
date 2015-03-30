# -*- encoding : utf-8 -*-
class ActionController::Base
  def safe_render(*args)
    return if performed?
    render(*args)
  end
end

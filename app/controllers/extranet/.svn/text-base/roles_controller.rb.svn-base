class Extranet::RolesController < ApplicationController

  def index
    @roles =Role.all
    @tasks =Task.all
  end

  def update
    RolesTask.transaction do
      RolesTask.delete_all
      if params[:perm]
        for role in Role.all
          for task in Task.all
            if params[:perm]["#{task.id}-#{role.id}-write"] == "on"
              RolesTask.create(:task_id => task.id,:role_id => role.id,:read => 1 ,:write => 1)
            elsif params[:perm]["#{task.id}-#{role.id}-read"] == "on"
              RolesTask.create(:task_id => task.id,:role_id => role.id,:read => 1 ,:write => 0)
            end
          end
        end
      end
    end
    flash[:notice] = "Settings have been saved."
    redirect_to :back
  end

end

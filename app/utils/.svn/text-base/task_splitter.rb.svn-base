
class TaskSplitter
  def initialize(proc_task, split_by, params ={})
    @proc_task = proc_task
    @split_by = split_by
    @params = params
  end

  def perform
    result = []
    @split_by.in_groups_of(@params[:split_count], false) do |group|
      result << @proc_task.call(group, @params)
    end
    result.flatten
  end
end

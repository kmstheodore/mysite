class TasksController < ApplicationController
  
  def index
    @tasks = current_user.tasks
  end
  def new
    @task = Task.new
  end

  def create
    @task = current_user.tasks.build(task_params)

    if @task.save
      redirect_to tasks_path, notice: 'Task was successfully created.'
    else
      render :new
    end
  end

  private

  def task_params
    params.require(:task).permit(:name, :strike)
  end
end

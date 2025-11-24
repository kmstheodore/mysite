class EventsController < ApplicationController
  def new
    @task = Task.new
  end
end

class Api::EventsController < ApplicationController
  before_action :set_event, only: [:show, :update, :destroy]

  def index
    events = Event.by_status(params[:status]).ordered_by_start_date(sort_direction)
    render json: events
  end

  def show
    render json: @event
  end

  def create
    event = Event.new(event_params)

    if event.save
      render json: event, status: :created
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @event.update(event_params)
      render json: @event
    else
      render json: { errors: @event.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @event.destroy
    head :no_content
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :description, :start_date, :end_date, :status)
  end

  def sort_direction
    params[:sort] == "desc" ? :desc : :asc
  end
end

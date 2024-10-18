class ConsumptionsController < ApplicationController
  #before_action :configure_permitted_parameters, only: [:show]
  respond_to :json, :html

  def index
  end

  def show
    client = current_user.clients.find_by(service_number: params[:id])
    date = Date.parse(params[:date])
    render json: { service_number: params[:id], date: date, hourly_consumptions: client.hourly_consumptions(date) } 
  end

  #def configure_permitted_parameters
  #  devise_parameter_sanitizer.permit(:show, keys: [:id])
  #  #devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password, :app_tag, :remember_me])
  #end
end

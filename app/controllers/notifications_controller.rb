class NotificationsController < ApplicationController
  #before_action :configure_permitted_parameters, only: [:show]
  respond_to :json, :html

  def index
  end

  def show
    client = current_user.clients.find_by(service_number: params[:id])

    render json: { notifications: client.notification_summary } 
  end

  #def configure_permitted_parameters
  #  devise_parameter_sanitizer.permit(:show, keys: [:id])
  #  #devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password, :app_tag, :remember_me])
  #end
end

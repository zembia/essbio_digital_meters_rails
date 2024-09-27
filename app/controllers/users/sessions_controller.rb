# frozn_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  respond_to :json, :html

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    #unless request.format == :json
    #    sign_out
    #    render status: 406, json: { message: "Solo solicitudes JSON" } and return
    #end
    puts "create!"
    app = App.find_by(tag: params["user"]["app_tag"])
    request.params["user"]["app_id"] = app.id unless app.nil?

    resource = warden.authenticate!(auth_options)
    render status: 400, json: { error: "Credenciales inválidas" } and return if resource.blank?
      
    sign_in(:user, resource)
    respond_with resource, location:
      after_sign_in_path_for(resource) do |format|
        format.json do
          # render json: { success: true, jwt: current_token, response: "Autenticación exitosa" }
          user_meters = nil
          this_user = { email: resource.email, name: "name", meters: user_meters}
          render json: { user: this_user }
        end
      end

  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end
  #def destroy
  #  puts "destroy!"
  #  app = App.find_by(tag: params["user"]["app_tag"])
  #  request.params["user"]["app_id"] = app.id unless app.nil?
  #  super
  #end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:create, keys: [:email, :password, :app_tag, :remember_me])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password, :app_tag, :remember_me])
  end
end

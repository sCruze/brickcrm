class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_session_path, alert: "Слишком много попыток входа. Подождите." }

  def new
    redirect_to root_path if authenticated?
  end

  def create
    unless CrmConfig.password_auth?
      return redirect_to new_session_path, alert: "Вход по паролю отключён — используйте SSO"
    end

    user = User.active.authenticate_by(email: params[:email], password: params[:password])

    if user&.can_sign_in?
      start_new_session_for(user)
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Неверная почта или пароль, либо доступ в CRM не выдан"
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end

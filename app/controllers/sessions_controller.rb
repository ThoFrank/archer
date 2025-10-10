class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    # See if omniauth was used
    user_info = request.env["omniauth.auth"]
    if user_info
      user = User.find_by(email_address: user_info.info.email, password_digest: user_info.provider)
      user ||= User.create!(email_address: user_info.info.email, password_digest: user_info.provider)
    end

    # Fall back to local user
    user ||= User.authenticate_by(params.permit(:email_address, :password))

    if user
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to "/"
  end
end

class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :switch_locale
  before_action :set_hidden_home_btn

  def switch_locale(&action)
    locale = params[:locale] if I18n.locale_available? params[:locale]
    locale ||= :de
    I18n.with_locale(locale, &action)
  end

  def set_hidden_home_btn
    @home_hidden = params["hidden_home_btn"]
  end

  def default_url_options
    {
      locale: I18n.locale,
      hidden_home_btn: @home_hidden
    }
  end

  def set_tournament
    @tournament = Tournament.find(params[:tournament_id] || params[:id])
    raise ActiveRecord::RecordNotFound unless @tournament.is_a? Tournament
    if !authenticated? && @tournament.status == "archived"
      raise ActiveRecord::RecordNotFound
    end
  end
end

module Concerns::AuthenticationHandler
  extend ActiveSupport::Concern

  included do
    before_filter :require_basic_auth
    before_filter :set_return_to, if: -> { !current_user && params[:redirect_to].present? }
    before_filter :redirect_user_back_after_login, unless: :devise_controller?
    before_filter :configure_permitted_parameters, if: :devise_controller?
    before_filter :force_base_domain_with_ssl, if: :devise_controller?
    helper_method :base_domain

    def base_domain
      { host: ::Configuration[:base_domain] }
    end

    private

    def force_base_domain_with_ssl
      if channel
        redirect_to base_domain.merge(protocol: :https)
      end
    end

    def set_return_to
      if params[:redirect_to].present?
        session[:return_to] = "/#{params[:redirect_to]}"
        flash.alert = t('devise.failure.unauthenticated')
      end
    end

    def after_sign_in_path_for(resource_or_scope)
      session.delete(:return_to) || root_path
    end

    def redirect_user_back_after_login
      unless request.xhr?
        session[:return_to] = request.original_url
      end
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit(:name,
                 :email,
                 :password,
                 :newsletter,
                 [investment_prospect_attributes: [:value]])
      end
    end

    def require_basic_auth
      if request.url.match Regexp.new(black_list_domains.join("|"))
        authenticate_or_request_with_http_basic do |username, password|
          username == 'admin' && password == 'Streetcar4321'
        end
      end
    end

    def black_list_domains
      ['neighborly-staging.herokuapp.com',
       'invest.neighbor.ly',
       'staging.neighbor.ly',
       'channel.staging.neighbor.ly',
       'kaboom.neighbor.ly',
       'cfg.neighbor.ly',
       'makeitright.neighbor.ly']
    end
  end
end

module Admin
  class SessionsController < Devise::SessionsController

    before_action :ensure_html_format

    protected

    def after_sign_in_path_for(resource_or_scope)
      admin_dashboard_path #store_location_for(resource_or_scope) || super
    end

    def after_sign_out_path_for(resource_or_scope)
      root_path
    end

    def ensure_html_format
      request.format = :html unless request.format.html?
    end

  end

end

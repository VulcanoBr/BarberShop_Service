module Admin
  class SessionsController < Devise::SessionsController

    before_action :ensure_html_format

    def destroy
      # Faz logout APENAS do escopo :admin_user (ajuste se seu escopo for diferente)
      # warden é o middleware que Devise usa para autenticação
      signed_out = warden.logout(:admin_user) # Use o nome do seu scope/modelo Devise aqui

      # Define a mensagem flash (opcional, mas bom ter)
      set_flash_message! :notice, :signed_out if signed_out

      # Redireciona para o caminho definido após o logout
      redirect_to after_sign_out_path_for(:admin_user), status: :see_other # :see_other é apropriado para redirecionamento após DELETE
    end

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

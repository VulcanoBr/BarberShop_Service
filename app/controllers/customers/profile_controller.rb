
module Customers
  class ProfileController < BaseController

    def edit
      @customer = current_customer
    end

    def update
      @customer = current_customer

      if @customer.update(profile_params)
        redirect_to customers_profile_path, notice: "Perfil atualizado com sucesso!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def profile_params
      params.require(:customer).permit(:name, :phone)
    end
  end

end

module Admin

  class ServicesController < AdminController

    include Pagy::Backend

    before_action :set_service, only: [:show, :edit, :update, :destroy]

    def index
      @pagy_services, @services = pagy(Service.order(:name), page_param: :page_services, limit: 8)
    end

    def show
    end

    def new
      @service = Service.new
    end

    def edit
    end

    def create
      @service = Service.new(service_params)

      if @service.save
        redirect_to [:admin, @service], notice: 'Serviço criado com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @service.update(service_params)
        redirect_to [:admin, @service], notice: 'Serviço atualizado com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @service.destroy
      redirect_to admin_services_path, notice: 'Serviço removido com sucesso.'
    end

    private

    def set_service
      @service = Service.find(params[:id])
    end

    def service_params
      params.require(:service).permit(:name, :price, :duration, :description, :active )
    end
  end

end

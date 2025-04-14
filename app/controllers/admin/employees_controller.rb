module Admin

  class EmployeesController < AdminController

    #before_action :authenticate_admin!
    before_action :set_employee, only: [:show, :edit, :update, :destroy]

    def index
      @employees = Employee.order(:name)
    end

    def show
    end

    def new
      @employee = Employee.new
    end

    def edit
    end

    def create
      @employee = Employee.new(employee_params)

      if @employee.save
        redirect_to [:admin, @employee], notice: 'Funcionario criado com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @employee.update(employee_params)
        redirect_to [:admin, @employee], notice: 'Funcionario atualizado com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @employee.destroy
      redirect_to admin_employees_path, notice: 'Funcionario removido com sucesso.'
    end

    private

    def set_employee
      @employee = Employee.find(params[:id])
    end

    def employee_params
      params.require(:employee).permit(:name, :surname, :active )
    end
  end

end

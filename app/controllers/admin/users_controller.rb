module Admin
  class UsersController < AdminController
    def index
      @users = User.all
      
      # Поиск по имени, email, телефону
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @users = @users.where(
          "username ILIKE ? OR email ILIKE ? OR phone ILIKE ?",
          search_term, search_term, search_term
        )
      end
      
      # Фильтрация по роли
      if params[:role].present?
        @users = @users.where(role: params[:role])
      end
      
      @users = @users.order(created_at: :desc)
                    .page(params[:page]).per(20)
      
      @role_filter = params[:role]
    end
    
    def show
      @user = User.find(params[:id])
      @bookings = @user.bookings.includes(room: :hotel).order(created_at: :desc)
    end
    
    def update
      @user = User.find(params[:id])
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "Пользователь обновлен"
      else
        redirect_to admin_users_path, alert: "Ошибка при обновлении"
      end
    end
    
    def destroy
      @user = User.find(params[:id])
      if @user.bookings.exists?
        redirect_to admin_users_path, alert: "Нельзя удалить пользователя с активными бронированиями"
      else
        @user.destroy
        redirect_to admin_users_path, notice: "Пользователь удалён"
      end
    end
    
    private
    
    def user_params
      params.require(:user).permit(:username, :email, :phone, :role, :has_visa)
    end
  end
end
class ProfilesController < ApplicationController
  before_action :require_login

  def show
    @user = current_user
    @recent_bookings = @user.bookings.includes(room: :hotel).order(created_at: :desc).limit(5)
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Данные профиля успешно обновлены"
    else
      # Перенаправляем обратно на страницу редактирования
      redirect_to profile_path(edit: true), alert: @user.errors.full_messages.to_sentence
    end
  end

  private

  def profile_params
    params.require(:user).permit(:username, :email, :phone, :has_visa)
  end
end
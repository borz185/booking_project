module Admin
  class AdminController < ApplicationController
    before_action :require_admin
    
    def dashboard
      @stats = {
        hotels_count: Hotel.count,
        rooms_count: Room.count,
        users_count: User.count,
        bookings_count: Booking.count,
        recent_bookings: Booking.includes(:user, room: :hotel).order(created_at: :desc).limit(10),
        recent_users: User.order(created_at: :desc).limit(10)
      }
    end
    
    private
    
    def require_admin
      unless logged_in? && current_user.admin?
        redirect_to root_path, alert: "Доступ запрещен. Требуется роль администратора."
      end
    end
  end
end
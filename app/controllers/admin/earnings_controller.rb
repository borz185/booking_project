module Admin
  class EarningsController < AdminController
    def index
      @earnings = Earning.includes(:booking, :hotel)
                        .order(earned_at: :desc)
                        .page(params[:page]).per(20)
      
      # Фильтрация по периоду
      if params[:period].present?
        case params[:period]
        when 'today'
          @earnings = @earnings.today
        when 'month'
          @earnings = @earnings.this_month
        when 'year'
          @earnings = @earnings.this_year
        end
      end
      
      # Поиск по отелю
      if params[:hotel_search].present?
        @earnings = @earnings.joins(:hotel)
                            .where("hotels.name ILIKE ?", "%#{params[:hotel_search]}%")
      end
      
      # Метрики
      @metrics = {
        today: Earning.total_today,
        this_month: Earning.total_this_month,
        this_year: Earning.total_this_year,
        all_time: Earning.total_all_time,
        count: @earnings.count
      }
    end
  end
end